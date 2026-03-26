extends PanelContainer

var commandListNode
var commandList
var cmdButtonsList
var currentPage
var maxPages

var nextButtonNode
var prevButtonNode

var fNum

signal new_menu_selected(menu)
signal screen_number_selected(screenNum)
signal shortcut_remove_selected(slotNum)
signal shortcut_slot_selected(slotNum)
signal shortcut_type_selected(typeNum)
signal shortcut_command_selected(commandString)




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	fNum = 0
	
	if get_node("MarginContainer/HBoxContainer/VBoxContainer/CommandListContainer"):
		commandListNode = get_node("MarginContainer/HBoxContainer/VBoxContainer/CommandListContainer")
		nextButtonNode = get_node("MarginContainer/HBoxContainer/Next/NextButton")
		prevButtonNode = get_node("MarginContainer/HBoxContainer/Back/BackButton")
		
		nextButtonNode.hide()
		prevButtonNode.hide()
		
		print("Commands menu.")
	else:
		print("Not commands menu.")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if commandList and !cmdButtonsList and fNum == 45:
		setupCommandsMenu()
	elif commandList and !cmdButtonsList:
		fNum += 1



func updateCommandsDisplay():
	for child in commandListNode.get_children():
		commandListNode.remove_child(child)
		
	var first = (currentPage-1)*3
	
	for i in range(first, first+3):
		if i < cmdButtonsList.size():
			commandListNode.add_child(cmdButtonsList[i])
			
	nextButtonNode.show()
	prevButtonNode.show()
			
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
	print("Shortcut slot selected. | ", extra_arg_0)
	emit_signal("shortcut_slot_selected", extra_arg_0)


func _add_shortcut_type(extra_arg_0: int) -> void:
	print("Shortcut type pressed. | ", extra_arg_0)
	emit_signal("shortcut_type_selected", extra_arg_0)


func _add_shortcut_command(extra_arg_0: String) -> void:
	print("Shortcut command selected. | ", extra_arg_0)
	emit_signal("shortcut_command_selected", extra_arg_0)
	emit_signal("new_menu_selected", "main")


func _on_del_shortcut_num_pressed(extra_arg_0: int) -> void:
	emit_signal("shortcut_remove_selected", extra_arg_0)
	emit_signal("new_menu_selected", "main")




func _next_command_list() -> void:
	if currentPage < maxPages:
		currentPage += 1
		updateCommandsDisplay()


func _prev_command_list() -> void:
	if currentPage > 1:
		currentPage -= 1
		updateCommandsDisplay()


func setupCommandsMenu():

	cmdButtonsList = []
	currentPage = 1
	
	for app in commandList.keys():
		var button = Button.new()
		button.text = app
		
		var path = commandList[app]
		button.pressed.connect(_add_shortcut_command.bind(path))
		
		cmdButtonsList.append(button)
		
		maxPages = ceil(cmdButtonsList.size() / 3.0)
		
	updateCommandsDisplay()
