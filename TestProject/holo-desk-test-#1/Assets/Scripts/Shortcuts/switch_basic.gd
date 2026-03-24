extends Node3D

var hingeComponentNode : XRToolsInteractableHinge ##Variable to hold the hinge component and access position.

@export var commandString : String ##Variable to store the command to be run.
var thread: Thread ##The thread that will be used to run the command non-blocking.

var hingePos : float ##The position of the hinge as a floating point number.
var hingeTriggered : bool ##Whether the hinge is or is not currently triggered.

var leverSlot : Node3D




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if hingeComponentNode == null:
		hingeComponentNode = self.get_node("LeverOrigin/InteractableLever")
		
	hingeTriggered = false




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	hingePos = hingeComponentNode.hinge_position
	
	if hingePos == hingeComponentNode.hinge_limit_max and hingeTriggered == false:
		call_deferred("_run_thread")
		hingeTriggered = true
		
	elif hingePos != hingeComponentNode.hinge_limit_max:
		hingeTriggered = false




# Called to start the thread that will run the shortcut's command.
func _run_thread():
	thread = Thread.new()
	thread.start(self.triggerCommand)



# Called to run the shortcut's command within the thread.
func triggerCommand():
	var output = []
	OS.execute(commandString, [""], output)
	return "done"
