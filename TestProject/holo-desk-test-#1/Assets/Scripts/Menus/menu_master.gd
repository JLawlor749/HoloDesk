extends Node3D

var menuViewportNode : XRToolsViewport2DIn3D

var screenManagerNode : Node3D
var shortcutManagerNode : Node3D

var mainMenu : PackedScene = preload("res://Assets/Menus/zone_wrist_ui.tscn")
var screenMenu : PackedScene = preload("res://Assets/Menus/screens_menu.tscn")
var envMenu : PackedScene = preload("res://Assets/Menus/zone_wrist_ui.tscn")
var shortMenu : PackedScene = preload("res://Assets/Menus/shortcuts_menu.tscn")
var optMenu : PackedScene = preload("res://Assets/Menus/zone_wrist_ui.tscn")

var addScut : PackedScene = preload("res://Assets/Menus/add_shortcut_menu.tscn")
var deleteScut : PackedScene = preload("res://Assets/Menus/delete_shortcut_menu.tscn")

var fNum = 0




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menuViewportNode = self.get_node("Viewport2Din3D")
	menuViewportNode.scene_node.menuMasterNode = self

	screenManagerNode = get_node("/root/Root/ScreenManager")
	shortcutManagerNode = get_node("/root/Root/ShortcutManager")



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
		
	elif targetScene == "add_shortcut":
		menuViewportNode.set_scene(addScut)
		
	elif targetScene == "delete_shortcut":
		menuViewportNode.set_scene(deleteScut)




func setScreenNumber(targetNum):
	screenManagerNode.updateScreenNumber(targetNum)




func addShortcut(targetSlot, commandString):
	shortcutManagerNode.addShortcut(targetSlot, commandString)




func removeShortcut(targetSlot):
	shortcutManagerNode.removeShortcut(targetSlot)
