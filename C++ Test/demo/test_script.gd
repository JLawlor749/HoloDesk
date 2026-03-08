extends Node3D
@export var driverController : DriverController;
var counter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	driverController.enableDevice("ROOT\\MttVDD")
	counter = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	counter += 1
	if counter == 3600:
		driverController.disableDevice("ROOT\\MttVDD")
