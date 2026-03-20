extends PanelContainer

var menuMasterNode

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
	menuMasterNode.setMenuScene("select_shortcut_type")


func _on_del_shortcut_num_pressed(extra_arg_0: int) -> void:
	menuMasterNode.removeShortcut(extra_arg_0)


func _add_shortcut_type(extra_arg_0: int) -> void:
	menuMasterNode.setMenuScene("select_shortcut_command")
