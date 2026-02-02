import ctypes
from ctypes import wintypes

# =========================
# Win32 setup
# =========================

user32 = ctypes.WinDLL("user32", use_last_error=True)

# =========================
# Constants
# =========================

QDC_ALL_PATHS = 0x00000001
QDC_ONLY_ACTIVE_PATHS = 0x00000002

DISPLAYCONFIG_PATH_ACTIVE = 0x00000001

DISPLAYCONFIG_DEVICE_INFO_GET_ADAPTER_NAME = 0x00000002
DISPLAYCONFIG_DEVICE_INFO_GET_TARGET_NAME  = 0x00000003

# =========================
# Structures
# =========================

class LUID(ctypes.Structure):
    _fields_ = [
        ("LowPart", wintypes.DWORD),
        ("HighPart", wintypes.LONG),
    ]

class DISPLAYCONFIG_PATH_SOURCE_INFO(ctypes.Structure):
    _fields_ = [
        ("adapterId", LUID),
        ("id", wintypes.UINT),
        ("modeInfoIdx", wintypes.UINT),
        ("statusFlags", wintypes.UINT),
    ]

class DISPLAYCONFIG_PATH_TARGET_INFO(ctypes.Structure):
    _fields_ = [
        ("adapterId", LUID),
        ("id", wintypes.UINT),
        ("modeInfoIdx", wintypes.UINT),
        ("outputTechnology", wintypes.UINT),
        ("rotation", wintypes.UINT),
        ("scaling", wintypes.UINT),
        ("refreshRateNumerator", wintypes.UINT),
        ("refreshRateDenominator", wintypes.UINT),
        ("scanLineOrdering", wintypes.UINT),
        ("statusFlags", wintypes.UINT),
    ]

class DISPLAYCONFIG_PATH_INFO(ctypes.Structure):
    _fields_ = [
        ("sourceInfo", DISPLAYCONFIG_PATH_SOURCE_INFO),
        ("targetInfo", DISPLAYCONFIG_PATH_TARGET_INFO),
        ("flags", wintypes.UINT),
    ]

class DISPLAYCONFIG_VIDEO_SIGNAL_INFO(ctypes.Structure):
    _fields_ = [
        ("pixelRate", ctypes.c_ulonglong),
        ("hSyncFreqNumerator", wintypes.UINT),
        ("hSyncFreqDenominator", wintypes.UINT),
        ("vSyncFreqNumerator", wintypes.UINT),
        ("vSyncFreqDenominator", wintypes.UINT),
        ("activeSize_cx", wintypes.UINT),
        ("activeSize_cy", wintypes.UINT),
        ("totalSize_cx", wintypes.UINT),
        ("totalSize_cy", wintypes.UINT),
        ("scanLineOrdering", wintypes.UINT),
    ]

class DISPLAYCONFIG_TARGET_MODE(ctypes.Structure):
    _fields_ = [("targetVideoSignalInfo", DISPLAYCONFIG_VIDEO_SIGNAL_INFO)]

class DISPLAYCONFIG_MODE_INFO(ctypes.Structure):
    _fields_ = [
        ("infoType", wintypes.UINT),
        ("id", wintypes.UINT),
        ("adapterId", LUID),
        ("targetMode", DISPLAYCONFIG_TARGET_MODE),
    ]

class DISPLAYCONFIG_DEVICE_INFO_HEADER(ctypes.Structure):
    _fields_ = [
        ("type", wintypes.UINT),
        ("size", wintypes.UINT),
        ("adapterId", LUID),
        ("id", wintypes.UINT),
    ]

class DISPLAYCONFIG_ADAPTER_NAME(ctypes.Structure):
    _fields_ = [
        ("header", DISPLAYCONFIG_DEVICE_INFO_HEADER),
        ("adapterDevicePath", wintypes.WCHAR * 260),
    ]

class DISPLAYCONFIG_TARGET_DEVICE_NAME(ctypes.Structure):
    _fields_ = [
        ("header", DISPLAYCONFIG_DEVICE_INFO_HEADER),
        ("flags", wintypes.UINT),
        ("outputTechnology", wintypes.UINT),
        ("edidManufactureId", wintypes.USHORT),
        ("edidProductCodeId", wintypes.USHORT),
        ("connectorInstance", wintypes.UINT),
        ("monitorFriendlyDeviceName", wintypes.WCHAR * 64),
        ("monitorDevicePath", wintypes.WCHAR * 260),
    ]

# =========================
# Function prototypes
# =========================

user32.GetDisplayConfigBufferSizes.argtypes = [
    wintypes.UINT,
    ctypes.POINTER(wintypes.UINT),
    ctypes.POINTER(wintypes.UINT),
]
user32.GetDisplayConfigBufferSizes.restype = wintypes.LONG

user32.QueryDisplayConfig.argtypes = [
    wintypes.UINT,
    ctypes.POINTER(wintypes.UINT),
    ctypes.POINTER(DISPLAYCONFIG_PATH_INFO),
    ctypes.POINTER(wintypes.UINT),
    ctypes.POINTER(DISPLAYCONFIG_MODE_INFO),
    ctypes.c_void_p,
]
user32.QueryDisplayConfig.restype = wintypes.LONG

user32.DisplayConfigGetDeviceInfo.argtypes = [
    ctypes.POINTER(DISPLAYCONFIG_DEVICE_INFO_HEADER)
]
user32.DisplayConfigGetDeviceInfo.restype = wintypes.LONG

# =========================
# Helper functions
# =========================

def luid_to_tuple(luid):
    return (luid.HighPart, luid.LowPart)

def query_display_config():
    path_count = wintypes.UINT()
    mode_count = wintypes.UINT()

    res = user32.GetDisplayConfigBufferSizes(
        QDC_ONLY_ACTIVE_PATHS,
        ctypes.byref(path_count),
        ctypes.byref(mode_count),
    )
    if res != 0:
        raise ctypes.WinError(res)

    paths = (DISPLAYCONFIG_PATH_INFO * path_count.value)()
    modes = (DISPLAYCONFIG_MODE_INFO * mode_count.value)()

    res = user32.QueryDisplayConfig(
        QDC_ONLY_ACTIVE_PATHS,
        ctypes.byref(path_count),
        paths,
        ctypes.byref(mode_count),
        modes,
        None,
    )
    if res != 0:
        raise ctypes.WinError(res)

    return paths, modes

def get_adapter_name(adapter_id):
    req = DISPLAYCONFIG_ADAPTER_NAME()
    req.header.type = DISPLAYCONFIG_DEVICE_INFO_GET_ADAPTER_NAME
    req.header.size = ctypes.sizeof(req)
    req.header.adapterId = adapter_id
    req.header.id = 0

    ptr = ctypes.cast(ctypes.byref(req), ctypes.POINTER(DISPLAYCONFIG_DEVICE_INFO_HEADER))
    res = user32.DisplayConfigGetDeviceInfo(ptr)
    if res != 0:
        return "<adapter name not available>"

    return req.adapterDevicePath

def get_target_name(adapter_id, target_id):
    req = DISPLAYCONFIG_TARGET_DEVICE_NAME()
    req.header.type = DISPLAYCONFIG_DEVICE_INFO_GET_TARGET_NAME
    req.header.size = ctypes.sizeof(req)
    req.header.adapterId = adapter_id
    req.header.id = target_id

    ptr = ctypes.cast(ctypes.byref(req), ctypes.POINTER(DISPLAYCONFIG_DEVICE_INFO_HEADER))
    res = user32.DisplayConfigGetDeviceInfo(ptr)
    print("res: ", res)
    if res != 0:
        return "<target name not available>"

    return req.monitorFriendlyDeviceName

# =========================
# Main logic
# =========================

try:
    paths, modes = query_display_config()
except Exception as e:
    print("Failed to query display configuration:", e)
    exit(1)

if not paths:
    print("No active display paths found.")
    exit(0)

print(f"Found {len(paths)} active display paths\n")

# Group paths by adapter LUID
adapters = {}
for path in paths:
    luid = luid_to_tuple(path.targetInfo.adapterId)
    adapters.setdefault(luid, []).append(path)

# Print adapters and their displays with resolution
for luid, adapter_paths in adapters.items():
    adapter_id = adapter_paths[0].targetInfo.adapterId
    adapter_name = get_adapter_name(adapter_id)

    print("Adapter LUID:", luid)
    print("Adapter Device Path:", adapter_name)

    for path in adapter_paths:
        active = bool(path.flags & DISPLAYCONFIG_PATH_ACTIVE)
        target_id = path.targetInfo.id

        # Names may be unavailable
        try:
            target_name = get_target_name(adapter_id, target_id)
        except:
            target_name = "<n/a>"

        # Get resolution from modeInfoIdx
        mode_idx = path.targetInfo.modeInfoIdx
        if mode_idx < len(modes):
            mode = modes[mode_idx]
            width = mode.targetMode.targetVideoSignalInfo.activeSize_cx
            height = mode.targetMode.targetVideoSignalInfo.activeSize_cy
            resolution = f"{width}x{height}"
        else:
            resolution = "<unknown>"

        print(
            f"  Target ID {target_id} | "
            f"Active: {active} | "
            f"Output Technology: {path.targetInfo.outputTechnology} | "
            f"Resolution: {resolution} | "
            f"Name: {target_name}"
        )

    print("\n\n")
