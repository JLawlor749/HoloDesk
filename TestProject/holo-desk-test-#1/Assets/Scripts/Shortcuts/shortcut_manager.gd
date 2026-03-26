extends Node3D

var slots ##List variable to store the shortcut slots.

var buttonScene
var leverScene = preload("res://Items/Shortcuts/simple_switch_red.tscn")

var shortcutCommandsDictionary


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	slots = []
	
	for i in range(0, 4):
		var tempSlot = get_node("Slot" + str(i+1))
		slots.append(tempSlot)
		
	print("Slots: ", slots)
	
	var commandsFile = FileAccess.open("user://user_commands.txt", FileAccess.READ)
	if !commandsFile:
		commandsFile = FileAccess.open("user://user_commands.txt", FileAccess.WRITE)
	commandsFile.close()
	commandsFile = null
	
	var commonApps = getCommonApps()
	var userCommands = getCommandsFromFile()
	commonApps.merge(userCommands)
	shortcutCommandsDictionary = commonApps




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func addShortcut(targetSlot, targetType, targetCommand):
	if targetType == 0:
		print("Add shortcut: ", targetSlot, "Button", targetCommand)
	else:
		print("Add shortcut: ", targetSlot, "Lever", targetCommand)
		
		var newLever = leverScene.instantiate()
		var leverSlot = get_node("Slot" + str(targetSlot))
		newLever.slot = leverSlot
		newLever.commandString = targetCommand
		
		leverSlot.add_child(newLever)




func removeShortcut(targetSlot):
	var deleteSlot = get_node("Slot" + str(targetSlot))
	var deleteShortcut = deleteSlot.get_child(0)
	deleteShortcut.queue_free()




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
		"Spotify": [
			"C:\\Program Files\\WindowsApps\\SpotifyAB.SpotifyMusic_1.285.519.0_x64__zpdnekdrzrea0\\Spotify.exe",
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
				found_apps[app_name] = "\"" + path + "\""
				break
				
	return found_apps




func getCommandsFromFile():
	# Open file and get contents as text.
	var commandsFile = FileAccess.open("user://user_commands.txt", FileAccess.READ)
	var fileContent = commandsFile.get_as_text()
	
	# Set up the dictionary that will contain these commands.
	var commandsDict = {}
	
	#Setup regex to seperate commands from each other.
	var lineRegex = RegEx.create_from_string("<.*?>")
	
	var seperateCommands = lineRegex.search_all(fileContent)
	
	var nameRegex = RegEx.create_from_string("name=\\[.*?\\]")
	var commandRegex = RegEx.create_from_string("command=\\[.*?\\]")
	
	for i in seperateCommands:
		var cmdText = i.get_string()
		var tempName = nameRegex.search(cmdText)
		var tempCommand = commandRegex.search(cmdText)
		
		var nameClean = RegEx.create_from_string("name=\\[")
		var commandClean = RegEx.create_from_string("command=\\[")
		var tailClean = RegEx.create_from_string("\\]")
		
		tempName = nameClean.sub(tempName.get_string(), "")
		tempName = tailClean.sub(tempName, "")
		
		tempCommand = commandClean.sub(tempCommand.get_string(), "")
		tempCommand = tailClean.sub(tempCommand, "")
		
		commandsDict[tempName] = tempCommand
		
	return commandsDict
	
	
	
	
