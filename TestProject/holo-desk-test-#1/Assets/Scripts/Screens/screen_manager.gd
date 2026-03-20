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
	await get_tree().create_timer(5).timeout
	
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




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Disable the digital display driver.
		driverHelper.disableDevice(hardwareID)
		
		var settingsFile = FileAccess.open("C:/VirtualDisplayDriver/vdd_settings.xml", FileAccess.READ_WRITE)
		var fileContent = settingsFile.get_as_text()
		
		var regex = RegEx.create_from_string("(?<=<count>)\\d+(?=</count>)")
		
		var result = regex.sub(fileContent, str(1), true)
		
		settingsFile.store_string(result)




func updateScreenNumber(targetNum : int):
	# Open file and get contents as text.
	var settingsFile = FileAccess.open("C:/VirtualDisplayDriver/vdd_settings.xml", FileAccess.READ_WRITE)
	var fileContent = settingsFile.get_as_text()
	
	# Define a REGEX to search for instances of a number between count tags.
	var regex = RegEx.create_from_string("(?<=<count>)\\d+(?=</count>)")
	
	# Substitute the number found by the REGEX with the number provided to the function.
	var result = regex.sub(fileContent, str(targetNum), true)
	
	# Store the new text back as a string to the XML file.
	settingsFile.store_string(result)
	settingsFile.close()
	settingsFile = null
	
	# Restart the driver to start simulation of new screen, or end simulation of old ones.
	driverHelper.restartDevice(hardwareID)
	await get_tree().create_timer(5).timeout
	
	# Calculate the difference in the target number of screens to the current number.
	var screenDiff = targetNum - (screenCount-1)
	
	# If there's no difference, we don't need to do anything.
	if screenDiff == 0:
		return
	
	# If the difference is negative, we need to remove screens.
	elif screenDiff < 0:
		# For each screen to be removed, we traverse from the end of the screen list and remove instances.
		for i in range(0, abs(screenDiff)):
			var target = screenList[(len(screenList)-1)-i]
			target.queue_free()
		
	# Otherwise, we need to add screens.
	else:
		# For each screen to be added, we create new instances and add them to the screen list.
		for i in range(0, abs(screenDiff)):
			# The index for each screen is the index of the previous one, plus 1.
			var index = (screenList[(len(screenList)-1)].get_node("Screen").screenIndex) + 1
			print("Updating... Adding Screen ", index, ": ", DisplayServer.screen_get_size(index))
			
			# Instantiate new screen.
			var tempScreen = screenScene.instantiate()
			
			# Get screen component holding script.
			var screenMesh = tempScreen.get_node("Screen")
			
			# Set the index to its number.
			screenMesh.screenIndex = index
			add_child(tempScreen)
			
			# Add the new screen to the screen list.
			screenList.append(tempScreen)
	
	print("screenCount: ", screenCount)
	print("screenlist: ", len(screenList))
	print("screenDiff: ", screenDiff)
