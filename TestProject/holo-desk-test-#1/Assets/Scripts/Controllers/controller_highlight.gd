extends Node3D

var controller: XRController3D
var model: MeshInstance3D

var AXbuttonPressed = false
var BYbuttonPressed = false

var gripPressed = false
var triggerPressed = false

@export var baseMat : Material
@export var highlightMat : Material

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	controller = self.get_parent().get_parent()
	model = self.get_parent()
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if controller.is_button_pressed("by_button"):
		setMaterial(highlightMat, 3)
	else:
		setMaterial(baseMat, 3)
		
	if controller.is_button_pressed("ax_button"):
		setMaterial(highlightMat, 4)
	else:
		setMaterial(baseMat, 4)
	
	if controller.is_button_pressed("grip_click"):
		setMaterial(highlightMat, 5)
	else:
		setMaterial(baseMat, 5)
		
	if controller.is_button_pressed("trigger_click"):
		setMaterial(highlightMat, 6)
	else:
		setMaterial(baseMat, 6)
	
	
func setMaterial(material, part):
	"""
	0 - Base
	1 - Joystick
	2 - Menu
	3 - UpperButton
	4 - LowerButton
	5 - Grip
	6 - Trigger
	"""
	model.set_surface_override_material(part, material)
