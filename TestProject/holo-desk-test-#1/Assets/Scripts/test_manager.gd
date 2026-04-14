extends Node3D

@export var runTest : bool
@export var menuViewportNode : XRToolsViewport2DIn3D
var menuScriptNode

@export var screenManager : Node3D
@export var shortcutManager : Node3D
@export var envManager : Node3D

var buttonScript = preload("res://Assets/Scripts/Shortcuts/button_basic.gd")
var switchScript = preload("res://Assets/Scripts/Shortcuts/switch_basic.gd")

var screensStarted : bool
var shortcutsStarted : bool
var envStarted : bool

var screensDone : bool
var shortcutsDone : bool
var envDone : bool

var logFile
var fileContent

var testSuccess : bool

# This script tests various combinations and triggers of the three main systems of the application.
# Each event or interaction is trigger directly from the menu functions, emulating how they'd be selected in real use.
# This script aims to test multiple different configurations of everything for the best possible coverage.


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screensDone = false
	shortcutsDone = false
	envDone = false
	
	screensStarted = false
	shortcutsStarted = false
	envStarted = false
	
	if runTest:
		menuScriptNode = menuViewportNode.get_scene_instance()
		
		testSuccess = true
		
		logFile = FileAccess.open("res://test_log.txt", FileAccess.WRITE)
		
		fileContent = "------ Starting Test Batch ------ " + Time.get_datetime_string_from_system() + " -------------------------------------\n\n"
		
		await get_tree().create_timer(10).timeout
		
		testScreens()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if screensDone and !shortcutsStarted:
		testShortcuts()
		
	if shortcutsDone and !envStarted:
		testEnvironments()
		
	if envDone:
		writeResultsToFile()





func testScreens():
	fileContent = fileContent + "\n--------- Starting Screens Test ---------------------------\n"
	fileContent = fileContent + "\n----- Stepped Test ---------------------\n"
	
	# Test each number of screens one by one in order.
	for i in range(1, 5):
		fileContent = fileContent + "Running with " + str(i) + " screens..."
		
		# Trigger screen update as if selected in menu.
		menuScriptNode._on_screen_num_pressed(i)
		
		# Wait to ensure screen has time to be fully initialized.
		await get_tree().create_timer(5).timeout
		
		# For the number of screens that are supposed to exist, look for each one.
		detectScreens(i)
			
		fileContent = fileContent + "\n\n"
		
	# Test each number of screens one by one in reverse order.
	for i in range(1, 4):
		i = 4 - i
		fileContent = fileContent + "Running with " + str(i) + " screens..."
		
		# Trigger screen update as if selected in menu.
		menuScriptNode._on_screen_num_pressed(i)
		
		# Wait to ensure screen has time to be fully initialized.
		await get_tree().create_timer(5).timeout
		
		# For the number of screens that are supposed to exist, look for each one.
		detectScreens(i)
			
		fileContent = fileContent + "\n\n"
	
	
	fileContent = fileContent + "\n----- Individual Test ---------------------\n"
	
	fileContent = fileContent + "TEST: Going from 1 screen to 4 screens.\n"
	fileContent = fileContent + "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
	fileContent = fileContent + "Setting to 1 screen..."
	menuScriptNode._on_screen_num_pressed(1)
	await get_tree().create_timer(3).timeout
	detectScreens(1)
	fileContent = fileContent + "\nSetting to 4 screens..."
	menuScriptNode._on_screen_num_pressed(4)
	await get_tree().create_timer(3).timeout
	detectScreens(4)
	
	fileContent = fileContent + "\n\n"
	
	fileContent = fileContent + "TEST: Going from 3 screens to 1 screen.\n"
	fileContent = fileContent + "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
	fileContent = fileContent + "Setting to 3 screens..."
	menuScriptNode._on_screen_num_pressed(3)
	await get_tree().create_timer(3).timeout
	detectScreens(3)
	fileContent = fileContent + "\nSetting to 1 screen..."
	menuScriptNode._on_screen_num_pressed(1)
	await get_tree().create_timer(3).timeout
	detectScreens(1)
	
	fileContent = fileContent + "\n\n"
	
	fileContent = fileContent + "TEST: Going from 2 screens to 4 screens.\n"
	fileContent = fileContent + "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
	fileContent = fileContent + "Setting to 2 screens..."
	menuScriptNode._on_screen_num_pressed(2)
	await get_tree().create_timer(3).timeout
	detectScreens(2)
	fileContent = fileContent + "\nSetting to 4 screen..."
	menuScriptNode._on_screen_num_pressed(4)
	await get_tree().create_timer(3).timeout
	detectScreens(4)
	
	fileContent = fileContent + "\n\n"
	
	fileContent = fileContent + "TEST: Going from 4 screens to 1 screen.\n"
	fileContent = fileContent + "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
	fileContent = fileContent + "Setting to 4 screens..."
	menuScriptNode._on_screen_num_pressed(4)
	await get_tree().create_timer(3).timeout
	detectScreens(4)
	fileContent = fileContent + "\nSetting to 1 screen..."
	menuScriptNode._on_screen_num_pressed(1)
	await get_tree().create_timer(3).timeout
	detectScreens(1)
	
	fileContent = fileContent + "\n\n--------- Finished Screens Test ---------------------------\n\n\n"
	
	screensDone = true




func testShortcuts():
	shortcutsStarted = true
	fileContent = fileContent + "\n\n--------- Starting Shortcuts Test ---------------------------\n"
	fileContent = fileContent + "\n----- Stepped Test ---------------------\n"
	
	# Test each shortcut slot with a switch.
	for i in range(1, 5):
		fileContent = fileContent + "TEST: shortcut slot " + str(i) + ", adding button.\n"
		fileContent = fileContent + "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
		
		menuScriptNode._on_add_shortcut_num_pressed(i)
		menuScriptNode._add_shortcut_type(0)
		menuScriptNode._add_shortcut_command("wt cmd /k \"ping google.com\"")
		
		# Have to reaquire the reference to the menu script node after setting command.
		# This is becuase setting the command tries to reset to the base menu.
		menuScriptNode = menuViewportNode.get_scene_instance()
		
		checkSlot(i, "button", "wt cmd /k \"ping google.com\"")
		
		
	fileContent = fileContent + "\nDeleting all shortcuts...\n"
	for i in range(1, 5):
		menuScriptNode._on_del_shortcut_num_pressed(i)
		menuScriptNode = menuViewportNode.get_scene_instance()
		
	await get_tree().process_frame
		
	for i in range(1, 5):
		var checkEmpty = shortcutManager.get_node("Slot" + str(i))
		if checkEmpty.get_child_count() == 0:
			fileContent = fileContent + "Successfully deleted from slot " + str(i) + ".\n"
		else:
			fileContent = fileContent + "Failed to delete from slot " + str(i) + ".\n"
	fileContent = fileContent + "\n\n"
		
		
	# Test each shortcut slot with a switch.
	for i in range(1, 5):
		fileContent = fileContent + "TEST: shortcut slot " + str(i) + ", adding switch.\n"
		fileContent = fileContent + "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
		
		menuScriptNode._on_add_shortcut_num_pressed(i)
		menuScriptNode._add_shortcut_type(1)
		menuScriptNode._add_shortcut_command("wt cmd /k \"ping google.com\"")
		
		# Have to reaquire the reference to the menu script node after setting command.
		# This is becuase setting the command tries to reset to the base menu.
		menuScriptNode = menuViewportNode.get_scene_instance()
		
		checkSlot(i, "switch", "wt cmd /k \"ping google.com\"")

	fileContent = fileContent + "--------- Finished Shortcuts Test ---------------------------\n\n\n"
	
	shortcutsDone = true




func testEnvironments():
	envStarted = true
	fileContent = fileContent + "\n\n--------- Starting Environments Test ---------------------------\n\n"
	
	fileContent = fileContent + "TEST: setting to GARDEN environment.\n"
	fileContent = fileContent + "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	menuScriptNode._on_environment_selected(1)
	await get_tree().create_timer(7).timeout
	checkEnv(1)
	menuScriptNode = menuViewportNode.get_scene_instance()
	
	fileContent = fileContent + "TEST: setting to TEMPLE environment.\n"
	fileContent = fileContent + "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	menuScriptNode._on_environment_selected(2)
	await get_tree().create_timer(7).timeout
	checkEnv(2)
	menuScriptNode = menuViewportNode.get_scene_instance()
	
	fileContent = fileContent + "TEST: setting to LAB environment.\n"
	fileContent = fileContent + "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	menuScriptNode._on_environment_selected(3)
	await get_tree().create_timer(7).timeout
	checkEnv(3)
	menuScriptNode = menuViewportNode.get_scene_instance()
	
	fileContent = fileContent + "TEST: setting to OFFICE environment.\n"
	fileContent = fileContent + "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	menuScriptNode._on_environment_selected(0)
	await get_tree().create_timer(7).timeout
	checkEnv(0)
	menuScriptNode = menuViewportNode.get_scene_instance()
	
	fileContent = fileContent + "--------- Finished Environments Test ---------------------------\n\n\n"
	
	envDone = true



func detectScreens(numTarget):
	for i in range(1, numTarget+1):
		
		# Try to find each screen as a child of the screen manager.
		var getScreen = screenManager.get_node("VirtualScreen" + str(i))
		var scriptNode = getScreen.get_node("Screen")
		
		# If the result isn't null, the screen exists, and the test succeeds.
		if getScreen != null and scriptNode.screenIndex == i:
			fileContent = fileContent + "\nVerified VirtualScreen" + str(i) + "."
		else:
			fileContent = fileContent + "\nERROR: VirtualScreen" + str(i) + "invalid or not detected."
			testSuccess = false




func checkSlot(slotNum, expectedShortcut, expectedCommand):
	var checkedSlot = shortcutManager.get_node("Slot" + str(slotNum))
	var target = checkedSlot.get_child(0)
	
	var typeValid = false
	var commandValid = false
	
	if target != null:
		if expectedShortcut == "button":
			if target.get_script() == buttonScript:
				typeValid = true
			
		if expectedShortcut == "switch":
			if target.get_script() == switchScript:
				typeValid = true
				
		if target.commandString == expectedCommand:
			commandValid = true
			
		if commandValid and typeValid:
			fileContent = fileContent + "\nShortcut " + expectedShortcut + " in Slot " + str(slotNum) + " verified.\n\n"
		else:
			fileContent = fileContent + "\nERROR: Shortcut in Slot " + str(slotNum) + " invalid. " + str(target.get_script().resource_path) + "\n\n"
			testSuccess = false
		
		
	else:
		fileContent = fileContent + "\nERROR: Shortcut in Slot " + str(slotNum) + " not detected.\n\n"
		testSuccess = false




func checkEnv(expectedEnv):
	var world = get_node("/root/Root/World/")
	var worldCount = world.get_child_count()
	var currentEnv = world.get_child(worldCount-1)
	
	var checkEnvir = null
	
	if expectedEnv == 0:
		checkEnvir = currentEnv.get_node("Office")
		
	elif expectedEnv == 1:
		checkEnvir = currentEnv.get_node("Garden")
		
	elif expectedEnv == 2:
		checkEnvir = currentEnv.get_node("Temple")
		
	else:
		checkEnvir = currentEnv.get_node("Lab")
		
	if expectedEnv == null:
		fileContent = fileContent + "\nERROR: No environment or incorrect environment detected.\n\n"
	else:
		fileContent = fileContent + "\nEnvironment verified.\n\n"



func writeResultsToFile():
	print("Writing Results To File.....")
	
	screensDone = false
	shortcutsDone = false
	envDone = false
	
	if testSuccess:
		fileContent = fileContent + "\nALL TESTS SUCCESSFUL!!!" 
	else:
		fileContent = fileContent + "\nTEST FAILURE." 
	
	fileContent = fileContent + "\n------ Finishing Test Batch ------ " + Time.get_datetime_string_from_system() + " -------------------------------------"
	print(fileContent)
	
	logFile.store_string(fileContent)
	logFile.close()
	logFile = null
