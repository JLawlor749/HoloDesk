extends Node3D

@export var menuViewportNode : XRToolsViewport2DIn3D
var menuScriptNode

@export var screenManager : Node3D
@export var shortcutManager : Node3D
@export var envManager : Node3D

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
	menuScriptNode = menuViewportNode.get_scene_instance()
	
	testSuccess = true
	
	logFile = FileAccess.open("res://test_log.txt", FileAccess.WRITE)
	
	fileContent = "------ Starting Test Batch ------ " + Time.get_datetime_string_from_system() + " -------------------------------------\n\n"
	
	await get_tree().create_timer(10).timeout
	
	testScreens()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if screensDone and !shortcutsDone:
		#testShortcuts()
		pass
		
	if shortcutsDone and !envDone:
		#testEnvironments()
		pass
		
	if shortcutsDone and envDone and screensDone:
		pass





func testScreens():
	fileContent = fileContent + "\n--------- Starting Stepped Screens Test -----------------\n"
	
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
	
	
	fileContent = fileContent + "\n--------- Starting Individual Screen Tests -------------\n"
	
	fileContent = fileContent + "TEST: Going from 1 screen to 4 screens.\n"
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
	fileContent = fileContent + "Setting to 4 screens..."
	menuScriptNode._on_screen_num_pressed(4)
	await get_tree().create_timer(3).timeout
	detectScreens(4)
	fileContent = fileContent + "\nSetting to 1 screen..."
	menuScriptNode._on_screen_num_pressed(1)
	await get_tree().create_timer(3).timeout
	detectScreens(1)
	
	fileContent = fileContent + "\n\n"
	writeResultsToFile()




func testShortcuts():
	pass




func testEnvironments():
	pass




func detectScreens(numTarget):
	for i in range(1, numTarget+1):
		
		# Try to find each screen as a child of the screen manager.
		var getScreen = screenManager.get_node("VirtualScreen" + str(i))
		
		# If the result isn't null, the screen exists, and the test succeeds.
		if getScreen != null:
			fileContent = fileContent + "\nVerified existence of VirtualScreen" + str(i) + "."
		else:
			fileContent = fileContent + "\nERROR: VirtualScreen" + str(i) + "not detected."
			testSuccess = false




func writeResultsToFile():
	print("Writing Results To File.....")
	
	if testSuccess:
		fileContent = fileContent + "\nALL TESTS SUCCESSFUL!!!" 
	else:
		fileContent = fileContent + "\nTEST FAILURE." 
	
	fileContent = fileContent + "\n------ Finishing Test Batch ------ " + Time.get_datetime_string_from_system() + " -------------------------------------"
	print(fileContent)
	
	logFile.store_string(fileContent)
	logFile.close()
	logFile = null
