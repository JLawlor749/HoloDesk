extends Node3D

var screenSize ##Vector2 to store the size of the screen.
var screenWidth
var screenHeight

var screenPos ##Vector2 to store the relative position of the screen (in Windows Display Settings).

var screenMesh ##The mesh on which the screen content will be displayed.

var screenCap ##Variable to store the screen capture taken of the display.
var texture ##Variable to store the texture that will be made from screenCap.
var material ##The material that the texture made from screenCap will be applied to.

var screenIndex ##The index number of this screen (primary is 0, simulated are 1-5).

var fCount ##A count variable to track the number of frames.

var grabPoint ##Variable to store the grabbable parent node.
var grabIndicator ##Variable used to add the mesh indicator for the grabbable.

var mouseCursorSprite ##Variable to store the mouse cursor sprite node.

var globalMouse ##Variable to store the global mouse position.
var localMouse ##Variable to store the mouse position local to this screen.

var inside ##Variable to determine whether the mouse is inside this screen or not.

var uv ##Vector2 to store the 2D position of the cursor sprite.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Create a new material.
	material = StandardMaterial3D.new()
	material.shading_mode = 0
	
	# Access the DisplayServer class and get the size of the screen.
	screenSize = DisplayServer.screen_get_size(screenIndex)
	
	# Set the scale of the 3D mesh plane to the size of the screen, scaled down.
	screenWidth = float(screenSize[0])/2000
	screenHeight = float(screenSize[1])/2000
	
	# Assign pickable component.
	grabPoint = self.get_parent()
	grabPoint.position += Vector3(screenIndex*1.25, 0, 0)
	grabIndicator = grabPoint.get_node("GrabIndicator")
	
	# Assign screen mesh.
	screenMesh = self.get_node("ScreenMesh")
	screenMesh.scale = Vector3(screenWidth, screenHeight, 1)
	
	# Assign mouse cursor component.
	mouseCursorSprite = self.get_node("CursorMesh")
	
	# Access the DisplayServer class and get the position of the screen.
	screenPos = DisplayServer.screen_get_position(screenIndex)
	
	# Capture the content on the screen, convert it to an image texture,
	# and set as the colour of the material.
	screenCap = DisplayServer.screen_get_image(screenIndex)
	texture = ImageTexture.create_from_image(screenCap)
	material.albedo_texture = texture
	
	# Apply the new material to the mesh.
	screenMesh.material_override = material
	
	fCount = 0
	
	print("Created screen: " + str(screenIndex))



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	fCount += 1
	
	# Capture the content on the screen, and update the texture with new content.
	if fCount % 2 == 0:
		screenCap = DisplayServer.screen_get_image(screenIndex)
		texture.update(screenCap)
		
	# Capture the global mouse position to update the cursor.
	globalMouse = DisplayServer.mouse_get_position()
	screenPos = DisplayServer.screen_get_position(screenIndex)
	
	# Get the position of the mouse local to this screen.
	localMouse = globalMouse - screenPos
	
	# If the position local to this screen is within the screen, inside is true.
	inside = (
		localMouse.x >= 0 and
		localMouse.y >= 0 and
		localMouse.x < screenSize.x and
		localMouse.y < screenSize.y
	)
	
	# If the mouse is in this screen, we can update position and draw it.
	if inside == true:
		mouseCursorSprite.show()
		uv = Vector2(localMouse) / Vector2(screenSize)
		var curX = remap(uv[0], 0, 1, -1*(screenWidth/2), (screenWidth/2))
		var curY = remap(uv[1], 0, 1, (screenHeight/2), -1*(screenHeight/2))
		
		mouseCursorSprite.position = Vector3(curX, curY, 0.01)
		
	else:
		mouseCursorSprite.hide()
	
	

	
	
	
