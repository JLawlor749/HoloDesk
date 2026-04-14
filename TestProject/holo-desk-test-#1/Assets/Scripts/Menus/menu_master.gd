extends Node3D

var menuViewportNode : XRToolsViewport2DIn3D
var menuUINode : PanelContainer

var screenManagerNode : Node3D
var shortcutManagerNode : Node3D
var environmentManagerNode : Node3D
var movementManagerNode : Node3D

var mainMenu : PackedScene = preload("res://Assets/Menus/zone_wrist_ui.tscn")
var screenMenu : PackedScene = preload("res://Assets/Menus/screens_menu.tscn")
var envMenu : PackedScene = preload("res://Assets/Menus/environment_menu.tscn")
var shortMenu : PackedScene = preload("res://Assets/Menus/shortcuts_menu.tscn")
var optMenu : PackedScene = preload("res://Assets/Menus/options_menu.tscn")

var confirmQuitMenu : PackedScene = preload("res://Assets/Menus/quit_confirm_menu.tscn")

var addScut : PackedScene = preload("res://Assets/Menus/add_shortcut_menu.tscn")
var deleteScut : PackedScene = preload("res://Assets/Menus/delete_shortcut_menu.tscn")

var scutType : PackedScene = preload("res://Assets/Menus/shortcut_type_menu.tscn")
var scutCommand : PackedScene = preload("res://Assets/Menus/shortcut_command_menu.tscn")

var shortcutSlot
var shortcutType
var shortcutCommand

var currentMovementMethod

var instructionsScene : PackedScene = preload("res://Assets/Menus/instructions_scene.tscn")
var currentInstructions

var fNum = 0




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menuViewportNode = self.get_node("Viewport2Din3D")
	menuUINode = menuViewportNode.scene_node

	screenManagerNode = get_node("/root/Root/ScreenManager")
	shortcutManagerNode = get_node("/root/Root/ShortcutManager")
	environmentManagerNode = get_node("/root/Root/EnvironmentManager")
	movementManagerNode = get_node("/root/Root/XROrigin3D/MovementManager")
	
	setMenuScene("main")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	fNum += 1
	
	if fNum == 360:
		pass



# Function responsible for changing menus as buttons are pressed.
func setMenuScene(targetScene : String):
	if targetScene == "screens":
		menuViewportNode.set_scene(screenMenu)
		
	# When moving to the shortcut menu, pass on information about whether all slots are full, or none are.
	elif targetScene == "shortcut":
		menuViewportNode.set_scene(shortMenu)
		menuUINode = menuViewportNode.scene_node
		menuUINode.slotsFull = shortcutManagerNode.allSlotsFull
		menuUINode.slotsEmpty = shortcutManagerNode.noSlotsFull
		
	elif targetScene == "environment":
		menuViewportNode.set_scene(envMenu)
		
	elif targetScene == "options":
		menuViewportNode.set_scene(optMenu)
		
	elif targetScene == "main":
		menuViewportNode.set_scene(mainMenu)
		shortcutSlot = null
		shortcutType = null
		shortcutCommand = null
		
	# Leads to the slots menu.
	elif targetScene == "add_shortcut":
		menuViewportNode.set_scene(addScut)
		
	elif targetScene == "delete_shortcut":
		menuViewportNode.set_scene(deleteScut)
		
	# There are no statements here for shortcut slots, types, or commands.
	# This is because the "add shortcut" menu leads directly to slots, which goes to type, then command.
	# This functions can be found below: setTargetSlot, setTargetType, setTargetCommand
		
	# The menu UI node reference has to be refreshed because a new menu is in place.
	menuUINode = menuViewportNode.scene_node
	setupNewMenu()
	
	# If we just switched to the options menu, set which movement method is selected.
	menuUINode.currentControlMethod = movementManagerNode.currentMovementMethod




func setScreenNumber(targetNum):
	screenManagerNode.updateScreenNumber(targetNum)



# Sets target slot, which is stored here in menu master, and moves to target type.
func setTargetSlot(targetSlot):
	#print("Shortcut slot being processed.")
	shortcutSlot = targetSlot
	menuViewportNode.set_scene(scutType)
	menuUINode = menuViewportNode.scene_node
	setupNewMenu()



# Sets target type, which is stored here in menu master, and moves to target command.
# This function also retrieves the shortcut commands from the shortcut manager, and passes them on to the command menu.
func setTargetType(targetType):
	#print("Shortcut type being processed.")
	shortcutType = targetType
	menuViewportNode.set_scene(scutCommand)
	menuUINode = menuViewportNode.scene_node
	menuUINode.commandList = shortcutManagerNode.shortcutCommandsDictionary
	setupNewMenu()
	



# Sets target command, and then passes slot, type, and command to shortcut manager to be processed.
func setTargetCommand(targetCommand):
	shortcutCommand = targetCommand
	shortcutManagerNode.addShortcut(shortcutSlot, shortcutType, shortcutCommand)




func removeShortcut(targetSlot):
	shortcutManagerNode.removeShortcut(targetSlot)




func setEnvironment(environmentNum):
	environmentManagerNode.startEnvironmentTransition(environmentNum)




func toggleMovementMethod():
	movementManagerNode.toggleMethod()




func createInstructionsObject():
	if currentInstructions == null or !is_instance_valid(currentInstructions):
		currentInstructions = instructionsScene.instantiate()
		var root = get_node("/root/Root")
		root.add_child(currentInstructions)




func confirmQuitApp():
	menuViewportNode.set_scene(confirmQuitMenu)
	menuUINode = menuViewportNode.scene_node
	setupNewMenu()




func quitApplication():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()




# Reconnects all of the menu signals for each new menu that is switched through.
func setupNewMenu():
	
	if not menuUINode.is_connected("new_menu_selected", setMenuScene):
		menuUINode.connect("new_menu_selected", setMenuScene)
		
	if not menuUINode.is_connected("screen_number_selected", setScreenNumber):
		menuUINode.connect("screen_number_selected", setScreenNumber)
		
	if not menuUINode.is_connected("shortcut_remove_selected", removeShortcut):
		menuUINode.connect("shortcut_remove_selected", removeShortcut)
		
	if not menuUINode.is_connected("shortcut_slot_selected", setTargetSlot):
		menuUINode.connect("shortcut_slot_selected", setTargetSlot)
		
	if not menuUINode.is_connected("shortcut_type_selected", setTargetType):
		menuUINode.connect("shortcut_type_selected", setTargetType)
		
	if not menuUINode.is_connected("shortcut_command_selected", setTargetCommand):
		menuUINode.connect("shortcut_command_selected", setTargetCommand)
		
	if not menuUINode.is_connected("environment_selected", setEnvironment):
		menuUINode.connect("environment_selected", setEnvironment)
		
	if not menuUINode.is_connected("control_toggled", toggleMovementMethod):
		menuUINode.connect("control_toggled", toggleMovementMethod)
		
	if not menuUINode.is_connected("first_quit_pressed", confirmQuitApp):
		menuUINode.connect("first_quit_pressed", confirmQuitApp)
		
	if not menuUINode.is_connected("second_quit_pressed", quitApplication):
		menuUINode.connect("second_quit_pressed", quitApplication)
		
	if not menuUINode.is_connected("instructions_pressed", createInstructionsObject):
		menuUINode.connect("instructions_pressed", createInstructionsObject)
