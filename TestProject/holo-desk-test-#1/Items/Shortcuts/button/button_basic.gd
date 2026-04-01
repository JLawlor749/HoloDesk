extends Node3D

var buttonComponentNode : XRToolsInteractableAreaButton ##Variable to hold the button component and access position.

@export var commandString : String ##Variable to store the command to be run.
var thread: Thread ##The thread that will be used to run the command non-blocking.

var buttonTriggered : bool ##Whether the button is or is not currently triggered.

var slot : Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if buttonComponentNode == null:
		buttonComponentNode = self.get_node("Base/XRToolsInteractableAreaButton")
		
	buttonTriggered = false




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if buttonComponentNode.pressed and buttonTriggered == false:
		call_deferred("_run_thread")
		buttonTriggered = true
		
	elif !buttonComponentNode.pressed:
		buttonTriggered = false
		
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
