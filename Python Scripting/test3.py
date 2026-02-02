import win32api

data = win32api.EnumDisplayMonitors()

for i in data:
    print(i, "\n")

print("\n\n\n\n")

data = []

for i in range(0,50):
    try:
        data.append(win32api.EnumDisplayDevices(DevNum=i))
    except:
        break

for i in range(len(data)):
    print(str(i)+". "+ data[i].DeviceName + " | " + data[i].DeviceString + " | " + data[i].DeviceID + " | " + data[i].DeviceKey)
    print("")