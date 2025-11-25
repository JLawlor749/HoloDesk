extends MeshInstance3D

var screenSize
var screenCap
var texture
var material
var screenIndex

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	self.position = Vector3(0, 1, -1.25)
	
	# Create a new material.
	material = StandardMaterial3D.new()
	
	# Access the DisplayServer class and get the size of the primary screen.
	screenSize = DisplayServer.screen_get_size(DisplayServer.SCREEN_PRIMARY)
	
	# Set the scale of the 3D mesh plane to the size of the screen, scaled down.
	self.scale = Vector3(float(screenSize[0])/1000, float(screenSize[1])/1000, 1)
	
	# Capture the content on the screen, convert it to an image texture,
	# and set as the colour of the material.
	screenCap = DisplayServer.screen_get_image(DisplayServer.SCREEN_PRIMARY)
	texture = ImageTexture.create_from_image(screenCap)
	material.albedo_texture = texture
	
	# Apply the new material to the mesh.
	self.material_override = material


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	# Capture the content on the screen, convert it to an image texture,
	# and set as the colour of the material.
	screenCap = DisplayServer.screen_get_image(DisplayServer.SCREEN_PRIMARY)
	texture = ImageTexture.create_from_image(screenCap)
	material.albedo_texture = texture
