extends Node

var driverHelper
var screenList
var screenScene = preload("res://Items/screen.tscn")
var screenPrimary
var sceneRoot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Gets the driver helper, which is the screen manager's child node.
	driverHelper = $ScreenManager/DriverHelper
	
	# Instantiate a new screen instance to display the user's real screen.
	# Assign it an index number of 0, as the first screen.
	screenPrimary = screenScene.instantiate()
	add_child(screenPrimary)
	
	var screenMesh = screenPrimary.get_node("Screen")
	screenMesh.screenIndex = 0
	
	# Start the list of screens with the primary screen.
	# The list item is the reference to the screen, and an index number.
	screenList = [[screenPrimary, 0]]
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
