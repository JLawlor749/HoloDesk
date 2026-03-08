#include <string>

#include "driverControl.h"
#include "deviceManager.h"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

DriverController::DriverController() {
	// Initialize any variables here.
}

DriverController::~DriverController() {
	// Add your cleanup here.
}

void DriverController::_bind_methods() {
	ClassDB::bind_method(D_METHOD("restartDevice", "hardwareId"), &DriverController::restartDevice);
    ClassDB::bind_method(D_METHOD("enableDevice", "hardwareId"), &DriverController::enableDevice);
    ClassDB::bind_method(D_METHOD("disableDevice", "hardwareId"), &DriverController::disableDevice);
}

int DriverController::restartDevice(String hardwareId)
{
    UtilityFunctions::print("Attempting to restart device...");
    return DeviceManager::restartDevice(hardwareId.utf8().get_data());
}

int DriverController::enableDevice(String hardwareId)
{
    UtilityFunctions::print("Attempting to enable device...");
    return DeviceManager::enableDevice(hardwareId.utf8().get_data());
}

int DriverController::disableDevice(String hardwareId)
{
    UtilityFunctions::print("Attempting to disable device...");
    return DeviceManager::disableDevice(hardwareId.utf8().get_data());
}