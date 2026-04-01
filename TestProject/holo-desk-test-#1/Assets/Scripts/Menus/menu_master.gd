extends Node3D

var menuViewportNode : XRToolsViewport2DIn3D
var menuUINode : PanelContainer

var screenManagerNode : Node3D
var shortcutManagerNode : Node3D
var environmentManagerNode : Node3D

var mainMenu : PackedScene = preload("res://Assets/Menus/zone_wrist_ui.tscn")
var screenMenu : PackedScene = preload("res://Assets/Menus/screens_menu.tscn")
var envMenu : PackedScene = preload("res://Assets/Menus/environment_menu.tscn")
var shortMenu : PackedScene = preload("res://Assets/Menus/shortcuts_menu.tscn")
var optMenu : PackedScene = preload("res://Assets/Menus/zone_wrist_ui.tscn")

var addScut : PackedScene = preload("res://Assets/Menus/add_shortcut_menu.tscn")
var deleteScut : PackedScene = preload("res://Assets/Menus/delete_shortcut_menu.tscn")

var scutType : PackedScene = preload("res://Assets/Menus/shortcut_type_menu.tscn")
var scutCommand : PackedScene = preload("res://Assets/Menus/shortcut_command_menu.tscn")

var shortcutSlot
var shortcutType
var shortcutCommand

var fNum = 0




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menuViewportNode = self.get_node("Viewport2Din3D")
	menuUINode = menuViewportNode.scene_node

	screenManagerNode = get_node("/root/Root/ScreenManager")
	shortcutManagerNode = get_node("/root/Root/ShortcutManager")
	environmentManagerNode = get_node("/root/Root/EnvironmentManager")
	
	setMenuScene("main")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	fNum += 1
	
	if fNum == 360:
		pass




func setMenuScene(targetScene : String):
	if targetScene == "screens":
		menuViewportNode.set_scene(screenMenu)
		
	elif targetScene == "shortcut":
		menuViewportNode.set_scene(shortMenu)
		
	elif targetScene == "environment":
		menuViewportNode.set_scene(envMenu)
		
	elif targetScene == "options":
		menuViewportNode.set_scene(optMenu)
		
	elif targetScene == "main":
		menuViewportNode.set_scene(mainMenu)
		shortcutSlot = null
		shortcutType = null
		shortcutCommand = null
		
	elif targetScene == "add_shortcut":
		menuViewportNode.set_scene(addScut)
		
	elif targetScene == "delete_shortcut":
		menuViewportNode.set_scene(deleteScut)
		
	menuUINode = menuViewportNode.scene_node
	setupNewMenu()




func setScreenNumber(targetNum):
	screenManagerNode.updateScreenNumber(targetNum)




func setTargetSlot(targetSlot):
	print("Shortcut slot being processed.")
	shortcutSlot = targetSlot
	menuViewportNode.set_scene(scutType)
	menuUINode = menuViewportNode.scene_node
	setupNewMenu()




func setTargetType(targetType):
	print("Shortcut type being processed.")
	shortcutType = targetType
	menuViewportNode.set_scene(scutCommand)
	menuUINode = menuViewportNode.scene_node
	menuUINode.commandList = shortcutManagerNode.shortcutCommandsDictionary
	setupNewMenu()
	




func setTargetCommand(targetCommand):
	shortcutCommand = targetCommand
	shortcutManagerNode.addShortcut(shortcutSlot, shortcutType, shortcutCommand)




func removeShortcut(targetSlot):
	shortcutManagerNode.removeShortcut(targetSlot)




func getCommandsList():
	return shortcutManagerNode.getCommonApps()




func setEnvironment(environmentNum):
	environmentManagerNode.startEnvironmentTransition(environmentNum)




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
