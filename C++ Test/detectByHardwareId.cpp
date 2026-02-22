#include <windows.h>
#include <setupapi.h>
#include <devguid.h>
#include <iostream>
#include <string>
#include <cfgmgr32.h>

// This line is used to link the required library files.
#pragma comment(lib, "setupapi.lib")
#pragma comment(lib, "cfgmgr32.lib")

// Function to determine if the hardware ID of a given device matches the template hardware ID.
// Parameters:
//		> HDEVINFO deviceInfoSet - handle to a device information set that contains device information elements. A device information set consists of device information elements for all the devices that belong to some device setup class or device interface class.
//		> SP_DEVINFO_DATA& deviceInfoData - a reference to a SP_DEVINFO_DATA structure. A SP_DEVINFO_DATA structure defines a device instance that is a member of a device information set. This represents one specific device from the previous parameter.
//		> const std::wstring& targetHardwareId - a read-only reference to a wstring, or wide string, which is used for larger character sets. This holds the hardware ID of the specific device we're looking for.
bool HardwareIdMatches(HDEVINFO deviceInfoSet, SP_DEVINFO_DATA& deviceInfoData, const std::wstring& targetHardwareId)
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



int main()
{
    // Define a new wide string for the target hardware ID.
    const std::wstring targetId = L"ROOT\\MttVDD";

    // Make a call to SetupDiGetClassDevs, which returns a handle to a device information set. The first paremeter is a pointer to the GUID of a device setup/interface class.
    // This call looks for the GUID of the Display class, because we're looking for display devices.
    HDEVINFO deviceInfoSet = SetupDiGetClassDevs(&GUID_DEVCLASS_DISPLAY, nullptr, nullptr, DIGCF_PRESENT);

    // If the device information set handle returned by SetupDiGetClassDevs is invalid, print an error.
    if (deviceInfoSet == INVALID_HANDLE_VALUE)
    {
        std::cout << "Failed to get device list.\n";
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
            std::wcout << L"\nFound matching device!\n";

            // We then define an buffer of wide characters for the instance ID, and a 32-bit unsigned int.
            wchar_t instanceId[1024];
            DWORD requiredSize = 0;

            // Calls the SetupDiGetDeviceInstanceId function, passing the device info set and a reference to the device info data. We also pass the instanceId variable for it to output to.
            if (SetupDiGetDeviceInstanceId(
                deviceInfoSet,
                &deviceInfoData,
                instanceId,
                sizeof(instanceId),
                &requiredSize))
            {
                // If it returns successfully, we can print it.
                std::wcout << L"Instance ID: " << instanceId << std::endl;
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
                std::wcout << L"Device Name: " << friendlyName << std::endl;
            }

            // Define unsigned long integers to store device information flags.
            ULONG deviceStatus = 0;
            ULONG deviceProblemNumber = 0;

            // Call CM_Get_DevNode_Status, passing deviceStatus and deviceProblemNumber as outputs, and the DevInst of the SP_DEVINFO_DATA as an instance handle.
            if (CM_Get_DevNode_Status(&deviceStatus, &deviceProblemNumber, deviceInfoData.DevInst, 0) != CR_SUCCESS)
            {
                std::cout << "Failed to get device status.\n";
                return 1;
            }

            // Using bitwise AND operations on the returned flags to determine the device state.
            if (deviceStatus & DN_STARTED)
            {
                std::wcout << L"Device " << friendlyName << " is ENABLED\n";
            }
            else if ((deviceStatus & DN_HAS_PROBLEM) && deviceProblemNumber == CM_PROB_DISABLED)
            {
                std::wcout << L"Device " << friendlyName << " is DISABLED\n";
            }
            else
            {
                std::wcout << L"Device " << friendlyName << " is in another state\n";
            }

            int userInput = 0;
            std::wcout << "Would you like to change the device state?\n1 - YES\n0 - NO\n";
            std::cin >> userInput;

            if (userInput == 1)
            {
                if (deviceStatus & DN_STARTED)
                {
                    if (!CM_Disable_DevNode(deviceInfoData.DevInst, 0) == CR_SUCCESS)
                    {
                        std::cout << "Failed to disable device.\n";
                        return 1;
                    }
                    else
                    {
                        std::cout << "Disabled device!\n";
                    }
                }
                else
                {
                    if (!CM_Enable_DevNode(deviceInfoData.DevInst, 0) == CR_SUCCESS)
                    {
                        std::cout << "Failed to enable device.\n";
                        return 1;
                    }
                    else
                    {
                        std::cout << "Enabled device!\n";
                    }
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