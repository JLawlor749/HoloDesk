extends Node3D

var slots ##List variable to store the shortcut slots.

var buttonScene
var leverScene = preload("res://Items/Shortcuts/simple_switch_red.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	slots = []
	
	for i in range(0, 4):
		var tempSlot = get_node("Slot" + str(i+1))
		slots.append(tempSlot)
		
	print("Slots: ", slots)




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func addShortcut(targetSlot, targetType, targetCommand):
	if targetType == 0:
		print("Add shortcut: ", targetSlot, "Button", targetCommand)
	else:
		print("Add shortcut: ", targetSlot, "Lever", targetCommand)
		
		var newLever = leverScene.instantiate()
		newLever.leverSlot = get_node("Slot" + str(targetSlot))




func removeShortcut(targetSlot):
	print("Remove shortcut: ", targetSlot)




func getCommonApps():
	var username = OS.get_environment("USERNAME")

	var apps = {
		"Chrome": [
			"C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
			"C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe"
		],
		"Firefox": [
			"C:\\Program Files\\Mozilla Firefox\\firefox.exe"
		],
		"Edge": [
			"C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe"
		],
		"Opera": [
			"C:\\Users\\%s\\AppData\\Local\\Programs\\Opera\\opera.exe" % username
		],
		"Word": [
			"C:\\Program Files\\Microsoft Office\\root\\Office16\\WINWORD.EXE",
			"C:\\Program Files (x86)\\Microsoft Office\\root\\Office16\\WINWORD.EXE"
		],
		"Excel": [
			"C:\\Program Files\\Microsoft Office\\root\\Office16\\EXCEL.EXE",
			"C:\\Program Files (x86)\\Microsoft Office\\root\\Office16\\EXCEL.EXE"
		],
		"PowerPoint": [
			"C:\\Program Files\\Microsoft Office\\root\\Office16\\POWERPNT.EXE",
			"C:\\Program Files (x86)\\Microsoft Office\\root\\Office16\\POWERPNT.EXE"
		],
		"MS Paint": [
			"C:\\Windows\\System32\\mspaint.exe"
		],
		"Notepad": [
			"C:\\Windows\\System32\\notepad.exe"
		],
		"Calculator": [
			"C:\\Windows\\System32\\calc.exe"
		],
		"Steam": [
			"C:\\Program Files (x86)\\Steam\\steam.exe"
		],
		"Blender": [
			"C:\\Program Files\\Blender Foundation\\Blender\\blender.exe"
		],
		"Epic Games Launcher": [
			"C:\\Program Files (x86)\\Epic Games\\Launcher\\Portal\\Binaries\\Win64\\EpicGamesLauncher.exe"
		],
		"Notepad++": [
			"C:\\Program Files\\Notepad++\\notepad++.exe",
			"C:\\Program Files (x86)\\Notepad++\\notepad++.exe"
		],
		"Discord": [
			"C:\\Users\\%s\\AppData\\Local\\Discord\\Update.exe" % username
		],
		"Spotify": [
			"C:\\Users\\%s\\AppData\\Roaming\\Spotify\\Spotify.exe" % username
		],
		"Audacity": [
			"C:\\Program Files\\Audacity\\audacity.exe"
		],
		"Teams": [
			"C:\\Users\\%s\\AppData\\Local\\Microsoft\\Teams\\current\\Teams.exe" % username
		],
		"7-Zip": [
			"C:\\Program Files\\7-Zip\\7zFM.exe"
		],
		"VLC": [
			"C:\\Program Files\\VideoLAN\\VLC\\vlc.exe",
			"C:\\Program Files (x86)\\VideoLAN\\VLC\\vlc.exe"
		],
		"VSCode": [
			"C:\\Users\\%s\\AppData\\Local\\Programs\\Microsoft VS Code\\Code.exe" % username
		]
	}
	
	var found_apps = {}
	
	for app_name in apps.keys():
		for path in apps[app_name]:
			if FileAccess.file_exists(path):
				found_apps[app_name] = path
				break
				
	return found_apps




func getCommandsFromFile():
	pass
