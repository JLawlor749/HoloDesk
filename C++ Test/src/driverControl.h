#ifndef DRIVER_CONTROLLER_H
#define DRIVER_CONTROLLER_H

#include <string>

#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/core/class_db.hpp>

namespace godot {

    class DriverController : public Node3D
    {
        GDCLASS(DriverController, Node3D)

        private:
            double test_var;

        protected:
            static void _bind_methods();

        public:
            DriverController();
            ~DriverController();

            int restartDevice(String hardwareId);
            int enableDevice(String hardwareId);
            int disableDevice(String hardwareId);
    };

}

#endif