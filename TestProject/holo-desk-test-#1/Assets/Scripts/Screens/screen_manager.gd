extends Node

@export var driverHelper : DriverController ##Variable to store a component to handle driver interactions.

var screenList ##List to hold all virtual screens. Should NOT include primary screen, index 0.

var screenCount ##Variable to store the number of total screens.

var screenScene = preload("res://Items/screen.tscn") ##Preloaded scene containing screen oject.

var screenPrimary ##To store the component representing the primary screen (physical device).

var hardwareID = "ROOT\\MttVDD" ##The hardware ID of the VDD.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Instantiate a new screen instance to display the user's real screen.
	print("Instantiating Primary Screen...")
	screenPrimary = screenScene.instantiate()
	
	# Assign a new variable to be the component of the screen object that holds the screen script.
	var screenDataStore = screenPrimary.get_node("Screen")
	
	#Assign it an index number of 0, as the first screen.
	print("Indexing Primary Screen...")
	screenDataStore.screenIndex = 0
	
	# Add it as a child of the screen manager.
	print("Activating Primary Screen...")
	add_child(screenPrimary)
	
	# Enable the digital display driver.
	driverHelper.enableDevice(hardwareID)
	await get_tree().create_timer(3).timeout
	
	# Now we can get the other, simulated screens, if any exist.
	screenCount = DisplayServer.get_screen_count()
	print(screenCount)
	
	# After getting the number of existing screens, we define an array to store them.
	screenList = Array()
	
	# We loop through all screens, except for the first one which has already been created.
	print("Instantiating Virtual Screens...\n")
	for i in range(1, screenCount):
		print("Screen ", i, ": ", DisplayServer.screen_get_size(i))
		
		# Instantiate new screen.
		var tempScreen = screenScene.instantiate()
		
		# Get screen component holding script.
		var screenMesh = tempScreen.get_node("Screen")
		
		# Set the index to its number.
		screenMesh.screenIndex = i
		add_child(tempScreen)
		
		# Add the new screen to the screen list.
		screenList.append(tempScreen)
		
	print("\nVirtual Screens Ready!")
	updateScreens(2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Disable the digital display driver.
		driverHelper.disableDevice(hardwareID)


func updateScreens(num : int):
	var settingsFile = FileAccess.open("C:/VirtualDisplayDriver/vdd_settings.xml", FileAccess.READ_WRITE)
	var fileContent = settingsFile.get_as_text()
	
	var regex = RegEx.create_from_string("(?<=<count>)\\d+(?=</count>)")
	
	var result = regex.sub(fileContent, str(num), true)
	
	settingsFile.store_string(result)
	
	driverHelper.restartDevice(hardwareID)
	
	screenCount = DisplayServer.get_screen_count()
	
	#var diff = (screenCount-1) - len(screenList)
	
	print("screenlist: ", len(screenList))
	print("screencount: ", screenCount)
	
	
