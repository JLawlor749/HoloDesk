#ifndef DEVICE_MANAGER_H
#define DEVICE_MANAGER_H

#include <windows.h>
#include <setupapi.h>
#include <cfgmgr32.h>
#include <string>

#pragma comment(lib, "setupapi.lib")
#pragma comment(lib, "cfgmgr32.lib")

class DeviceManager 
{
    public:
        static int restartDevice(const std::string& hardwareId);
        static int disableDevice(const std::string& hardwareId);
        static int enableDevice(const std::string& hardwareId);

    private:
        static bool HardwareIdMatches(HDEVINFO deviceInfoSet, SP_DEVINFO_DATA& deviceInfoData, const std::wstring& targetHardwareId);

};

#endif