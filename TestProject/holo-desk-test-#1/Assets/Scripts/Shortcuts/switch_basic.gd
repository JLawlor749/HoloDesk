extends Node3D

@export var hingeComponent : XRToolsInteractableHinge
@export var executablePath : String
@export var input : Array
var thread: Thread
var hingePos : float
var hingeTriggered : bool
var output := []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if hingeComponent == null:
		hingeComponent = self.get_node("LeverOrigin/InteractableLever")
		
	hingeTriggered = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	hingePos = hingeComponent.hinge_position
	
	if hingePos == hingeComponent.hinge_limit_max and hingeTriggered == false:
		call_deferred("_run_thread")
		hingeTriggered = true
		
	elif hingePos != hingeComponent.hinge_limit_max:
		hingeTriggered = false


func _run_thread():
	thread = Thread.new()
	thread.start(self.triggerCommand)


func triggerCommand():
	OS.execute(executablePath, input, output)
	return "done"
