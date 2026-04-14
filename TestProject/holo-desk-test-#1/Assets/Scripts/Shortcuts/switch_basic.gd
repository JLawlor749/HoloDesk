extends Node3D

var hingeComponentNode : XRToolsInteractableHinge ##Variable to hold the hinge component and access position.

@export var commandString : String ##Variable to store the command to be run.
var thread: Thread ##The thread that will be used to run the command non-blocking.

var hingePos : float ##The position of the hinge as a floating point number.
var hingeTriggered : bool ##Whether the hinge is or is not currently triggered.

var slot : Node3D

var handle : XRToolsPickable
var currentlyGrabbedBy




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if hingeComponentNode == null:
		hingeComponentNode = self.get_node("LeverOrigin/InteractableLever")
		
	hingeTriggered = false
	
	handle = get_node("LeverOrigin/InteractableLever/HandleOrigin/InteractableHandle")
	currentlyGrabbedBy = null
	
	handle.connect("grabbed", handleGrabbed)
	handle.connect("released", handleLetGo)
	
	
func vibrateController():
	var tracker = currentlyGrabbedBy.get_parent().get_tracker()
	var xr = XRServer.primary_interface
	if xr and tracker:
		xr.trigger_haptic_pulse("haptic", tracker, 0, 0.1, 1.0, 1.0)
		print("VIBRATE CONTROLLER!!!!!")


func handleGrabbed(pickable, by):
	currentlyGrabbedBy = by


func handleLetGo(pickable, by):
	currentlyGrabbedBy = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	hingePos = hingeComponentNode.hinge_position
	
	if hingePos == hingeComponentNode.hinge_limit_max and hingeTriggered == false:
		call_deferred("_run_thread")
		hingeTriggered = true
		vibrateController()
		
	elif hingePos != hingeComponentNode.hinge_limit_max:
		hingeTriggered = false
		
	if thread and not thread.is_alive():
		thread.wait_to_finish()
		print("Reset shortcut thread...")
		thread = null




# Called to start the thread that will run the shortcut's command.
func _run_thread():
	print("Trigger shortcut thread...")
	if thread == null:
		thread = Thread.new()
		thread.start(Callable(self, "triggerCommand"))



# Called to run the shortcut's command within the thread.
func triggerCommand():
	var output = []
	OS.execute("cmd.exe", ["/c", commandString], output)
	print("Ran command: ", commandString, "  |  ", output)
	return "done"
