extends Node3D
@export var driverController : DriverController;
var counter
var hardwareId

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hardwareId = "ROOT\\MttVDD"
	driverController.enableDevice(hardwareId)
	counter = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	counter += 1
	if counter == 1200:
		driverController.disableDevice(hardwareId)
