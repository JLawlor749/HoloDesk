extends Node3D

var teleportMovementNode
var joystickMovementNode

var currentMovementMethod


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentMovementMethod = 0
	
	teleportMovementNode = get_parent().get_node("LeftHand/FunctionTeleport")
	joystickMovementNode = get_parent().get_node("LeftHand/MovementDirect")
	teleportMovementNode.enabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	


func toggleMethod():
	print("Switching movement method...")
	if currentMovementMethod == 0:
		teleportMovementNode.enabled = true
		joystickMovementNode.enabled = false
		currentMovementMethod = 1
		
	elif currentMovementMethod == 1:
		joystickMovementNode.enabled = true
		teleportMovementNode.enabled = false
		currentMovementMethod = 0
