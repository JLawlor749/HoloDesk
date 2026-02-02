import win32api

data = win32api.EnumDisplaySettings("\\\\.\\DISPLAY1", 0)

print(
    f"""
SpecVersion: {data.SpecVersion}
DriverVersion: {data.DriverVersion}
Size: {data.Size}
DriverExtra: {data.DriverExtra}
Fields: {data.Fields}
Orientation: {data.Orientation}
PaperSize: {data.PaperSize}
PaperLength: {data.PaperLength}
PaperWidth: {data.PaperWidth}
Position_x: {data.Position_x}
Position_y: {data.Position_y}
DisplayOrientation: {data.DisplayOrientation}
DisplayFixedOutput: {data.DisplayFixedOutput}
Scale: {data.Scale}
Copies: {data.Copies}
DefaultSource: {data.DefaultSource}
PrintQuality: {data.PrintQuality}
Color: {data.Color}
Duplex: {data.Duplex}
YResolution: {data.YResolution}
TTOption: {data.TTOption}
Collate: {data.Collate}
LogPixels: {data.LogPixels}
> BitsPerPel: {data.BitsPerPel}
> PelsWidth: {data.PelsWidth}
> PelsHeight: {data.PelsHeight}
> DisplayFlags: {data.DisplayFlags}
> DisplayFrequency: {data.DisplayFrequency}
ICMMethod: {data.ICMMethod}
ICMIntent: {data.ICMIntent}
MediaType: {data.MediaType}
DitherType: {data.DitherType}
Reserved1: {data.Reserved1}
Reserved2: {data.Reserved2}
Nup: {data.Nup}
PanningWidth: {data.PanningWidth}
PanningHeight: {data.PanningHeight}
DeviceName: {data.DeviceName}
FormName: {data.FormName}
DriverData: {data.DriverData}
"""
)