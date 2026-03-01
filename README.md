# HoloDesk
Thisy project will consist of a virtual reality workspace, with a customizable background, environment, surroundings, and furnishings. It will feature the ability to add modular customizable viewports or screens to the workspace, which will emulate additional physical monitors connected to a host computer.

It will use the ![Virtual Display Driver](https://github.com/VirtualDrivers/Virtual-Display-Driver) by MikeTheTech to simulate the additional screens. A C++ script compiled to a GDExtension will be used to access the Windows Setup API and turn the driver on and off.

![Workspace Mockup](3dWorkspace.png)

<br><br>

### FYP To-Do List
___

**Driver Script**
* Change activation toggle to be a function.
* Add restart function.
* Compile as Godot Extension.
<br>

**Menu Systems**
* Screen Menu
* Shortcut Menu
* Environment Menu
* Main Menu
* Pause Menu
<br>

**Shortcut System**
* Menu
* Positioning System
* More Types - Trigger and Function
* Select Shortcut
<br>

**Environment System**
* More Environments - ~3
* Selection System
<br>

**Screen System**
* Change Sizes
* Mouse Cursor Capture
* Touchscreen (Experiment?)
* Add Menus - Select Number of Screens
<br>

![https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-sendinput](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-sendinput)  
![https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-input](https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-input)  
![https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-mouseinput](https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-mouseinput)  
<br>

It should, in theory, be possible to get the position on a MeshInstance3D of a flat plane where a touch component has intersected it,
and then feed those coordinates into a `MOUSEINPUT` structure, and give it to the `SendInput()` function.

The same would go for swiping up/down to scroll - the `MOUSEINPUT` structure can have a flag set for `MOUSEEVENTF_WHEEL`.

In the case of multiple monitors, the coordinates can be a bit weird. Coordinates start at an origin point of (0,0).
This point is mapped to the top-left corner of your designated Primary Monitor. Extra displays placed to the right of the
primary have coordinates starting from the end of the first monitor's width. If the extra display is to the left or above the
primary, they use negative coordinates.

This refers only to the display's position in terms of Windows display settings. While it might be possible to set up a system
to detect the position of the VR monitor and adjust the display settings to match, this would likely be very time consuming,
and ultimately not worth it, as this is something the user can easily change themselves from Windows display settings.

<br><br>


### Next Four Weeks - Monday 02/March to Sunday 29/March
___

**Tuesday 03/March - Thursday 05/March**
* Change activation toggle to be a function.
* Add restart function.
* Compile as Godot Extension.

**Saturday 07/March - Sunday 08/March**
* Screen Menu - Attached to wrist, select number of screens, LIFO setup.
* Integrate GDScript with GDExtension to change number of screens and restart driver.

**Tuesday 10/March - Sunday 15/March**
* Start working on shortcuts. 2 new buttons and 1 new lever.
* Set up position system.
* Set up menu - based on screen menu.
* Select shortcut type, then function, then position.
* Can stick with simply opening apps for now.

**Tuesday 17/March - Thursday 19/March**
* Environments - Make at least 3 more to go with office.
* Rework office environment - bake lighting, better textures.

**Saturday 21/March**
* Add environment menu, and system for switching environments.

**Sunday 22/March**
* Try adding 2 new shortcut types with finger touch sensor.

**Tuesday 24/March - Thursday 26/March**
* Pause Menu and Main Menu
* Add settings that might be important.
* If I have time, work on touch screen capability.

**Saturday 28/March - Sunday 29/March**
* Work on tutorial.
* Anything else that comes up.
* If I have time, work on touch screen capability.




![Godot Engine](https://img.shields.io/badge/Godot-000000?logo=godotengine)
![C++](https://img.shields.io/badge/C++-blue?logo=cplusplus)
![Blender](https://img.shields.io/badge/Blender-green?logo=blender)
