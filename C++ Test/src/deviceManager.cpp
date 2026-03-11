#define UNICODE
#include <windows.h>
#include <setupapi.h>
#include <cfgmgr32.h>
#include <devguid.h>
#include <string>

#include "deviceManager.h"

#include <godot_cpp/variant/utility_functions.hpp>

#pragma comment(lib, "setupapi.lib")
#pragma comment(lib, "cfgmgr32.lib")


bool DeviceManager::HardwareIdMatches(HDEVINFO deviceInfoSet, SP_DEVINFO_DATA& deviceInfoData, const std::wstring& targetHardwareId)
{
    // Declare buffer of length 4096 of wide characters.
    wchar_t buffer[4096];

    // Declared DWORD (32-bit unsigned int) for required size.
    DWORD requiredSize = 0;

    // Call the SetupDiGetDeviceRegistryProperty function. It retrieves the hardware ID of the device specified by deviceInfoData from deviceInfoSet, and stores it in buffer.
    if (!SetupDiGetDeviceRegistryProperty(
        deviceInfoSet,
        &deviceInfoData,
        SPDRP_HARDWAREID,
        nullptr,
        (PBYTE)buffer,
        sizeof(buffer),
        &requiredSize))
    {
        return false;
    }

    // At this point, the content of buffer is the hardware ID, stored as a MULTI_SZ value.
    // This is an implementation specific type that contains a sequence of null-terminated strings, terminated by an empty string (\0) so that the last two characters are both null terminators.

    // Create a pointer called current that points to the start of the buffer. To be used to look over each string.
    const wchar_t* current = buffer;

    // While the current string is not empty, i.e. while we are still looking at data.
    while (*current)
    {
        // Convert the string we're currently looking at to a wide string called hardwareId.
        std::wstring hardwareId = current;

        godot::UtilityFunctions::print("Current hardware ID: ");
        godot::UtilityFunctions::print(godot::String(hardwareId.c_str()));
        godot::UtilityFunctions::print("Target hardware ID: ");
        godot::UtilityFunctions::print(godot::String(targetHardwareId.c_str()));
        godot::UtilityFunctions::print("\n");

        // String comparison on the current string, and the template hardware ID passed as a parameter.
        if (_wcsicmp(hardwareId.c_str(), targetHardwareId.c_str()) == 0)
        {
            return true;
        }

        // Move the current pointer to the position immediately after the end of the current string, i.e. the start of the next one.
        current += hardwareId.length() + 1;
    }

    return false;
}

int DeviceManager::restartDevice(const std::string& hardwareId)
{
    //godot::UtilityFunctions::print("Beginning device restart...");

    // Define a new wide string for the target hardware ID.
    const std::wstring targetId(hardwareId.begin(), hardwareId.end());


    // Make a call to SetupDiGetClassDevs, which returns a handle to a device information set. The first paremeter is a pointer to the GUID of a device setup/interface class.
    // This call looks for the GUID of the Display class, because we're looking for display devices.
    HDEVINFO deviceInfoSet = SetupDiGetClassDevs(&GUID_DEVCLASS_DISPLAY, nullptr, nullptr, DIGCF_PRESENT);

    // If the device information set handle returned by SetupDiGetClassDevs is invalid, print an error.
    if (deviceInfoSet == INVALID_HANDLE_VALUE)
    {
        godot::UtilityFunctions::print("Failed to get device list.\n");
        SetupDiDestroyDeviceInfoList(deviceInfoSet);
        return 1;
    }

    // Define a SP_DEVINFO_DATA, the structure that defines a device instance that is a member of a device information set.
    SP_DEVINFO_DATA deviceInfoData;

    // Defines how large the structure will be, based on the SP_DEVINFO_DATA size.
    deviceInfoData.cbSize = sizeof(SP_DEVINFO_DATA);

    // Define an unsigned 32-bit integer intex.
    DWORD index = 0;

    // This while loop calls the SetupDiEnumDeviceInfo function. This takes a device information set, and an index, and returns the corresponding SP_DEVINFO_DATA structure into a pointer.
    // The loop will continue as long as the function doesn't return false, i.e. as long as there is still data to read.
    while (SetupDiEnumDeviceInfo(deviceInfoSet, index, &deviceInfoData))
    {

        // We use our function to check the current index from the device information set, and see if the hardware ID is a match.
        if (HardwareIdMatches(deviceInfoSet, deviceInfoData, targetId))
        {

            // If it is a match, we can print a message.
            godot::UtilityFunctions::print("\nFound matching device!\n");

            // We then define an buffer of wide characters for the instance ID, and a 32-bit unsigned int.
            wchar_t instanceId[1024];
            DWORD requiredSize = 0;

            // Calls the SetupDiGetDeviceInstanceId function, passing the device info set and a reference to the device info data. We also pass the instanceId variable for it to output to.
            if (SetupDiGetDeviceInstanceIdW(
                deviceInfoSet,
                &deviceInfoData,
                instanceId,
                sizeof(instanceId),
                &requiredSize))
            {
                // If it returns successfully, we can print it.
                godot::UtilityFunctions::print("Instance ID: ");
                godot::UtilityFunctions::print(instanceId);
                godot::UtilityFunctions::print("\n");
            }

            // Then define a buffer of wide characters for the friendly name.
            wchar_t friendlyName[1024];

            // Calls SetupDiGetDeviceRegistryProperty, which gets properties of Plug and Play devices. This one looks for description, or friendly device name.
            if (SetupDiGetDeviceRegistryProperty(
                deviceInfoSet,
                &deviceInfoData,
                SPDRP_DEVICEDESC,
                nullptr,
                (PBYTE)friendlyName,
                sizeof(friendlyName),
                &requiredSize))
            {
                godot::UtilityFunctions::print("Device Name: ");
                godot::UtilityFunctions::print(friendlyName);
                godot::UtilityFunctions::print("\n");
            }

            SP_PROPCHANGE_PARAMS restartParams = {};

            restartParams.StateChange = DICS_PROPCHANGE;
            restartParams.Scope = DICS_FLAG_GLOBAL;
            restartParams.HwProfile = 0;
            restartParams.ClassInstallHeader.InstallFunction = DIF_PROPERTYCHANGE;
            restartParams.ClassInstallHeader.cbSize = sizeof(SP_CLASSINSTALL_HEADER);

            SetupDiSetClassInstallParams(deviceInfoSet, &deviceInfoData, &restartParams.ClassInstallHeader, sizeof(SP_PROPCHANGE_PARAMS));

            if (SetupDiCallClassInstaller(DIF_PROPERTYCHANGE, deviceInfoSet, &deviceInfoData))
            {
                godot::UtilityFunctions::print("Device successfully restarted.");
            }
            else
            {
                godot::UtilityFunctions::print("Device restart code: ");
                godot::UtilityFunctions::print(static_cast<int>(GetLastError()));
                godot::UtilityFunctions::print("\n");
            }

            break;
        }

        // Increase the index for the next iteration.
        index++;
    }

    // We then destroy the device info set so as not to have a memory leak.
    SetupDiDestroyDeviceInfoList(deviceInfoSet);

    return 0;
}

int DeviceManager::enableDevice(const std::string& hardwareId)
{
    // Define a new wide string for the target hardware ID.
    const std::wstring targetId(hardwareId.begin(), hardwareId.end());

    // Make a call to SetupDiGetClassDevs, which returns a handle to a device information set. The first paremeter is a pointer to the GUID of a device setup/interface class.
    // This call looks for the GUID of the Display class, because we're looking for display devices.
    HDEVINFO deviceInfoSet = SetupDiGetClassDevs(&GUID_DEVCLASS_DISPLAY, nullptr, nullptr, DIGCF_PRESENT);

    // If the device information set handle returned by SetupDiGetClassDevs is invalid, print an error.
    if (deviceInfoSet == INVALID_HANDLE_VALUE)
    {
        godot::UtilityFunctions::print("Failed to get device list.\n");
        SetupDiDestroyDeviceInfoList(deviceInfoSet);
        return 1;
    }

    // Define a SP_DEVINFO_DATA, the structure that defines a device instance that is a member of a device information set.
    SP_DEVINFO_DATA deviceInfoData;

    // Defines how large the structure will be, based on the SP_DEVINFO_DATA size.
    deviceInfoData.cbSize = sizeof(SP_DEVINFO_DATA);

    // Define an unsigned 32-bit integer intex.
    DWORD index = 0;

    // This while loop calls the SetupDiEnumDeviceInfo function. This takes a device information set, and an index, and returns the corresponding SP_DEVINFO_DATA structure into a pointer.
    // The loop will continue as long as the function doesn't return false, i.e. as long as there is still data to read.
    while (SetupDiEnumDeviceInfo(deviceInfoSet, index, &deviceInfoData))
    {
        // We use our function to check the current index from the device information set, and see if the hardware ID is a match.
        if (HardwareIdMatches(deviceInfoSet, deviceInfoData, targetId))
        {

            // If it is a match, we can print a message.
            godot::UtilityFunctions::print("\nFound matching device!\n");

            // We then define an buffer of wide characters for the instance ID, and a 32-bit unsigned int.
            wchar_t instanceId[1024];
            DWORD requiredSize = 0;

            // Calls the SetupDiGetDeviceInstanceId function, passing the device info set and a reference to the device info data. We also pass the instanceId variable for it to output to.
            if (SetupDiGetDeviceInstanceIdW(
                deviceInfoSet,
                &deviceInfoData,
                instanceId,
                sizeof(instanceId),
                &requiredSize))
            {
                // If it returns successfully, we can print it.
                godot::UtilityFunctions::print("Instance ID: ");
                godot::UtilityFunctions::print(instanceId);
                godot::UtilityFunctions::print("\n");
            }

            // Then define a buffer of wide characters for the friendly name.
            wchar_t friendlyName[1024];

            // Calls SetupDiGetDeviceRegistryProperty, which gets properties of Plug and Play devices. This one looks for description, or friendly device name.
            if (SetupDiGetDeviceRegistryProperty(
                deviceInfoSet,
                &deviceInfoData,
                SPDRP_DEVICEDESC,
                nullptr,
                (PBYTE)friendlyName,
                sizeof(friendlyName),
                &requiredSize))
            {
                godot::UtilityFunctions::print("Device Name: ");
                godot::UtilityFunctions::print(friendlyName);
                godot::UtilityFunctions::print("\n");
            }

            // Define unsigned long integers to store device information flags.
            ULONG deviceStatus = 0;
            ULONG deviceProblemNumber = 0;

            // Call CM_Get_DevNode_Status, passing deviceStatus and deviceProblemNumber as outputs, and the DevInst of the SP_DEVINFO_DATA as an instance handle.
            if (CM_Get_DevNode_Status(&deviceStatus, &deviceProblemNumber, deviceInfoData.DevInst, 0) != CR_SUCCESS)
            {
                godot::UtilityFunctions::print("Failed to get device status.\n");
                SetupDiDestroyDeviceInfoList(deviceInfoSet);
                return 1;
            }

            // Using bitwise AND operations on the returned flags to determine the device state.
            if (deviceStatus & DN_STARTED)
            {
                godot::UtilityFunctions::print("Device is already enabled.");
            }
            else
            {
                if (!CM_Enable_DevNode(deviceInfoData.DevInst, 0) == CR_SUCCESS)
                {
                    godot::UtilityFunctions::print("Failed to enable device.");
                    SetupDiDestroyDeviceInfoList(deviceInfoSet);
                    return 1;
                }
                else
                {
                    godot::UtilityFunctions::print("Device successfully enabled.");
                }
            }

            break;
            
        }

        // Increase the index for the next iteration.
        index++;
    }

    // We then destroy the device info set so as not to have a memory leak.
    SetupDiDestroyDeviceInfoList(deviceInfoSet);

    return 0;    
}

int DeviceManager::disableDevice(const std::string& hardwareId)
{
    // Define a new wide string for the target hardware ID.
    const std::wstring targetId(hardwareId.begin(), hardwareId.end());

    // Make a call to SetupDiGetClassDevs, which returns a handle to a device information set. The first paremeter is a pointer to the GUID of a device setup/interface class.
    // This call looks for the GUID of the Display class, because we're looking for display devices.
    HDEVINFO deviceInfoSet = SetupDiGetClassDevs(&GUID_DEVCLASS_DISPLAY, nullptr, nullptr, DIGCF_PRESENT);

    // If the device information set handle returned by SetupDiGetClassDevs is invalid, print an error.
    if (deviceInfoSet == INVALID_HANDLE_VALUE)
    {
        godot::UtilityFunctions::print("Failed to get device list.\n");
        SetupDiDestroyDeviceInfoList(deviceInfoSet);
        return 1;
    }

    // Define a SP_DEVINFO_DATA, the structure that defines a device instance that is a member of a device information set.
    SP_DEVINFO_DATA deviceInfoData;

    // Defines how large the structure will be, based on the SP_DEVINFO_DATA size.
    deviceInfoData.cbSize = sizeof(SP_DEVINFO_DATA);

    // Define an unsigned 32-bit integer intex.
    DWORD index = 0;

    // This while loop calls the SetupDiEnumDeviceInfo function. This takes a device information set, and an index, and returns the corresponding SP_DEVINFO_DATA structure into a pointer.
    // The loop will continue as long as the function doesn't return false, i.e. as long as there is still data to read.
    while (SetupDiEnumDeviceInfo(deviceInfoSet, index, &deviceInfoData))
    {

        // We use our function to check the current index from the device information set, and see if the hardware ID is a match.
        if (HardwareIdMatches(deviceInfoSet, deviceInfoData, targetId))
        {

            // If it is a match, we can print a message.
            godot::UtilityFunctions::print("\nFound matching device!\n");

            // We then define an buffer of wide characters for the instance ID, and a 32-bit unsigned int.
            wchar_t instanceId[1024];
            DWORD requiredSize = 0;

            // Calls the SetupDiGetDeviceInstanceId function, passing the device info set and a reference to the device info data. We also pass the instanceId variable for it to output to.
            if (SetupDiGetDeviceInstanceIdW(
                deviceInfoSet,
                &deviceInfoData,
                instanceId,
                sizeof(instanceId),
                &requiredSize))
            {
                // If it returns successfully, we can print it.
                godot::UtilityFunctions::print("Instance ID: ");
                godot::UtilityFunctions::print(instanceId);
                godot::UtilityFunctions::print("\n");
            }

            // Then define a buffer of wide characters for the friendly name.
            wchar_t friendlyName[1024];

            // Calls SetupDiGetDeviceRegistryProperty, which gets properties of Plug and Play devices. This one looks for description, or friendly device name.
            if (SetupDiGetDeviceRegistryProperty(
                deviceInfoSet,
                &deviceInfoData,
                SPDRP_DEVICEDESC,
                nullptr,
                (PBYTE)friendlyName,
                sizeof(friendlyName),
                &requiredSize))
            {
                godot::UtilityFunctions::print("Device Name: ");
                godot::UtilityFunctions::print(friendlyName);
                godot::UtilityFunctions::print("\n");
            }

            // Define unsigned long integers to store device information flags.
            ULONG deviceStatus = 0;
            ULONG deviceProblemNumber = 0;

            // Call CM_Get_DevNode_Status, passing deviceStatus and deviceProblemNumber as outputs, and the DevInst of the SP_DEVINFO_DATA as an instance handle.
            if (CM_Get_DevNode_Status(&deviceStatus, &deviceProblemNumber, deviceInfoData.DevInst, 0) != CR_SUCCESS)
            {
                godot::UtilityFunctions::print("Failed to get device status.\n");
                SetupDiDestroyDeviceInfoList(deviceInfoSet);
                return 1;
            }

            // Using bitwise AND operations on the returned flags to determine the device state.
            if ((deviceStatus & DN_HAS_PROBLEM) && deviceProblemNumber == CM_PROB_DISABLED)
            {
                godot::UtilityFunctions::print("Device is already disabled.");
            }
            else
            {
                if (!CM_Disable_DevNode(deviceInfoData.DevInst, 0) == CR_SUCCESS)
                {
                    godot::UtilityFunctions::print("Failed to disable device.");
                    SetupDiDestroyDeviceInfoList(deviceInfoSet);
                    return 1;
                }
                else
                {
                    godot::UtilityFunctions::print("Device successfully disabled.");
                }
            }

            break;
            
        }

        // Increase the index for the next iteration.
        index++;
    }

    // We then destroy the device info set so as not to have a memory leak.
    SetupDiDestroyDeviceInfoList(deviceInfoSet);

    return 0;    
}
