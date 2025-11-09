extends MeshInstance3D

var screenSize
var screenCap
var texture
var material

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screenSize = DisplayServer.screen_get_size(DisplayServer.SCREEN_PRIMARY)
	self.scale = Vector3(float(screenSize[0])/1000, float(screenSize[1])/1000, 1)
	print(self.scale)
	screenCap = DisplayServer.screen_get_image(DisplayServer.SCREEN_PRIMARY)
	texture = ImageTexture.create_from_image(screenCap)
	material = StandardMaterial3D.new()
	material.albedo_texture = texture
	self.material_override = material


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	screenCap = DisplayServer.screen_get_image(DisplayServer.SCREEN_PRIMARY)
	texture = ImageTexture.create_from_image(screenCap)
	material.albedo_texture = texture
