extends Node3D

var viewportIn3D
var instUINode

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	viewportIn3D = get_node("Viewport2Din3D")
	instUINode = viewportIn3D.scene_node
	
	instUINode.connect("close_instructions_pressed", closeInstructions)
	self.position = Vector3(0, 1.5, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func closeInstructions():
	self.queue_free()
