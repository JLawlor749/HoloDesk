extends PanelContainer

var commandListNode
var commandList
var cmdButtonsList
var currentPage
var maxPages

var addShortcutButton
var delShortcutButton
var addShortcutSetup
var slotsFull
var slotsEmpty

var currentControlMethod
var controlMethodToggleButton
var controlToggleButtonSetup

var nextButtonNode
var prevButtonNode

var shortcutSlotsFull

var fNum

# These signals are for use with this script on menus.
# They emit upon different menu buttons being selected.
signal new_menu_selected(menu)
signal screen_number_selected(screenNum)
signal shortcut_remove_selected(slotNum)
signal shortcut_slot_selected(slotNum)
signal shortcut_type_selected(typeNum)
signal shortcut_command_selected(commandString)
signal environment_selected(environmentNum)
signal control_toggled()
signal first_quit_pressed()
signal second_quit_pressed()
signal instructions_pressed()

# This signal applies exclusively to the instructions list.
# It fires when the close button is pressed, and is used to remove the list.
signal close_instructions_pressed()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	fNum = 0
	
	# If the command list container is found, this is the commands menu, perform relevant setup.
	if get_node_or_null("MarginContainer/HBoxContainer/VBoxContainer/CommandListContainer"):
		commandListNode = get_node("MarginContainer/HBoxContainer/VBoxContainer/CommandListContainer")
		nextButtonNode = get_node("MarginContainer/HBoxContainer/Next/NextButton")
		prevButtonNode = get_node("MarginContainer/HBoxContainer/Back/BackButton")
		
		nextButtonNode.hide()
		prevButtonNode.hide()
		
	# If the add button from the shortcut menu is found, this is the shortcut menu, perform setup.
	if get_node_or_null("MarginContainer/VBoxContainer/HBoxContainer/AddButton"):
		addShortcutButton = get_node("MarginContainer/VBoxContainer/HBoxContainer/AddButton")
		delShortcutButton = get_node("MarginContainer/VBoxContainer/HBoxContainer/DeleteButton")
		
		addShortcutButton.hide()
		delShortcutButton.hide()
		
		addShortcutSetup = false
		
	# If the controls button is found, this is the options menu, perform setup.
	if get_node_or_null("MarginContainer/VBoxContainer/HBoxContainer/ControlsButton"):
		controlMethodToggleButton = get_node("MarginContainer/VBoxContainer/HBoxContainer/ControlsButton")
		
		controlToggleButtonSetup = false
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# If the menu master has passed the data for the commands list and the list hasn't been set up yet, wait 45 frames and then set it up.
	if commandList and !cmdButtonsList and fNum == 45:
		setupCommandsMenu()
		
	# Wait 45 frames to make the add and delete shortcut buttons visible, and disable one if the slots are either full or empty.
	if !addShortcutSetup and addShortcutButton and fNum == 45:
		if slotsFull:
			delShortcutButton.show()
		
		elif slotsEmpty:
			addShortcutButton.show()
			
		else:
			addShortcutButton.show()
			delShortcutButton.show()
			
	# If the menu master has passed the current control method and the toggle hasn't been set up, wait 45 frames then set it up.
	if !controlToggleButtonSetup and currentControlMethod and controlMethodToggleButton and fNum == 45:
		if currentControlMethod == 0:
			controlMethodToggleButton.text = "Teleport Movement"
			
		elif currentControlMethod == 1:
			controlMethodToggleButton.text = "Joystick Movement"
			
		controlToggleButtonSetup = true

	# Increment the frame tracker until it hits 46.
	if fNum <= 45:
		fNum += 1



func updateCommandsDisplay():
	# Get and remove all of the buttons currrently in the command list.
	for child in commandListNode.get_children():
		commandListNode.remove_child(child)
		
	# Get the first command in the new page being displayed by multiplying the page index by the items per page.
	var first = (currentPage-1)*3
	
	# For each of the three new buttons to be displayed in the list, add the relevant button as a child of the list.
	for i in range(first, first+3):
		if i < cmdButtonsList.size():
			commandListNode.add_child(cmdButtonsList[i])
			
	# Show both the next page and back page buttons.
	nextButtonNode.show()
	prevButtonNode.show()
			
	# If this is the last page, hide the next button. If this is the first page, hide the back button.
	if currentPage == maxPages:
		nextButtonNode.hide()
		
	if currentPage == 1:
		prevButtonNode.hide()




func _on_screens_button_pressed() -> void:
	emit_signal("new_menu_selected", "screens")


func _on_shortcut_button_pressed() -> void:
	emit_signal("new_menu_selected", "shortcut")


func _on_environment_button_pressed() -> void:
	emit_signal("new_menu_selected", "environment")


func _on_options_button_pressed() -> void:
	emit_signal("new_menu_selected", "options")


func _on_back_button_pressed() -> void:
	emit_signal("new_menu_selected", "main")


func _on_screen_num_pressed(extra_arg_0: int) -> void:
	emit_signal("screen_number_selected", extra_arg_0)


func _on_add_scut_button_pressed() -> void:
	emit_signal("new_menu_selected", "add_shortcut")


func _on_delete_scut_button_pressed() -> void:
	emit_signal("new_menu_selected", "delete_shortcut")


func _on_add_shortcut_num_pressed(extra_arg_0: int) -> void:
	emit_signal("shortcut_slot_selected", extra_arg_0)


func _add_shortcut_type(extra_arg_0: int) -> void:
	emit_signal("shortcut_type_selected", extra_arg_0)


func _add_shortcut_command(extra_arg_0: String) -> void:
	emit_signal("shortcut_command_selected", extra_arg_0)
	emit_signal("new_menu_selected", "main")


func _on_del_shortcut_num_pressed(extra_arg_0: int) -> void:
	emit_signal("shortcut_remove_selected", extra_arg_0)
	emit_signal("new_menu_selected", "main")


func _on_environment_selected(extra_arg_0: int) -> void:
	emit_signal("environment_selected", extra_arg_0)
	emit_signal("new_menu_selected", "main")
	
	
func _on_controls_toggle_pressed() -> void:
	print("Current Movement: ", currentControlMethod)
	if currentControlMethod == 0:
		currentControlMethod = 1
		controlMethodToggleButton.text = "Disable Teleport"
		
		
	elif currentControlMethod == 1:
		currentControlMethod = 0
		controlMethodToggleButton.text = "Enable Teleport"
	
	emit_signal("control_toggled")


func _on_quit_button_pressed() -> void:
	emit_signal("first_quit_pressed")


func _on_quit_for_real_button_pressed() -> void:
	emit_signal("second_quit_pressed")


func _on_instructions_button_pressed() -> void:
	emit_signal("instructions_pressed")


func _next_command_list() -> void:
	if currentPage < maxPages:
		currentPage += 1
		await get_tree().create_timer(1).timeout
		updateCommandsDisplay()


func _prev_command_list() -> void:
	if currentPage > 1:
		currentPage -= 1
		await get_tree().create_timer(1).timeout
		updateCommandsDisplay()


func setupCommandsMenu():
	# Create a list to store a button for each command.
	cmdButtonsList = []
	currentPage = 1
	
	# The command list is passed by the menu master, and is a dictionary with the names of commands as keys, and the commands as items.
	for app in commandList.keys():
		# For each item in the dictionary, the button text will be the name of the comman.
		var button = Button.new()
		button.text = app
		
		# Each button will be bound to the shortcut command signal, and will pass it's command text as an argument to the signalled function.
		var path = commandList[app]
		button.pressed.connect(_add_shortcut_command.bind(path))
		
		# Add each new button to the list.
		cmdButtonsList.append(button)
		
		# Figure out the maximum number of pages of three buttons per page.
		maxPages = ceil(cmdButtonsList.size() / 3.0)
		
	# Initialize the display with the newly created buttons.
	updateCommandsDisplay()


func _on_close_instructions_button_pressed() -> void:
	emit_signal("close_instructions_pressed")
