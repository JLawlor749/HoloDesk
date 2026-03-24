extends PanelContainer

var menuMasterNode

var commandListNode
var commandList
var cmdButtonsList
var currentPage
var maxPages

var nextButtonNode
var prevButtonNode

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Setting up new menu...")
	if menuMasterNode == null:
		await get_tree().create_timer(5).timeout
	
	commandListNode = get_node("MarginContainer/HBoxContainer/VBoxContainer/CommandListContainer")
	
	if commandListNode:
		commandList = menuMasterNode.getCommandsList()
		
		nextButtonNode = get_node("MarginContainer/HBoxContainer/Next/NextButton")
		prevButtonNode = get_node("MarginContainer/HBoxContainer/Back/BackButton")
		
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
			
	else:
		print("CommandList not found.")


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
	menuMasterNode.setMenuScene("screens")


func _on_shortcut_button_pressed() -> void:
	menuMasterNode.setMenuScene("shortcut")


func _on_environment_button_pressed() -> void:
	menuMasterNode.setMenuScene("environment")


func _on_options_button_pressed() -> void:
	menuMasterNode.setMenuScene("options")


func _on_back_button_pressed() -> void:
	menuMasterNode.setMenuScene("main")


func _on_screen_num_pressed(extra_arg_0: int) -> void:
	menuMasterNode.setScreenNumber(extra_arg_0)


func _on_add_scut_button_pressed() -> void:
	menuMasterNode.setMenuScene("add_shortcut")


func _on_delete_scut_button_pressed() -> void:
	menuMasterNode.setMenuScene("delete_shortcut")


func _on_add_shortcut_num_pressed(extra_arg_0: int) -> void:
	menuMasterNode.setTargetSlot(extra_arg_0)


func _add_shortcut_type(extra_arg_0: int) -> void:
	menuMasterNode.setTargetType(extra_arg_0)


func _add_shortcut_command(extra_arg_0: String) -> void:
	menuMasterNode.setTargetCommand(extra_arg_0)
	menuMasterNode.setMenuScene("main")


func _on_del_shortcut_num_pressed(extra_arg_0: int) -> void:
	menuMasterNode.removeShortcut(extra_arg_0)
	menuMasterNode.setMenuScene("main")


func _next_command_list() -> void:
	if currentPage < maxPages:
		currentPage += 1
		updateCommandsDisplay()


func _prev_command_list() -> void:
	if currentPage > 1:
		currentPage -= 1
		updateCommandsDisplay()
