extends Node3D

var user : XROrigin3D
var userBody : XRToolsPlayerBody

var environmentIndex

var targetEnvironment
var citySky = preload("res://Assets/Skys/086_hdrmaps_com_free_4K.exr")
var blueSky = preload("res://Assets/Skys/086_hdrmaps_com_free_4K.exr")

var worldNode : Node3D
var worldEnvNode : WorldEnvironment

var currentEnvironment

var envTransition : bool

var transitionBlocker : MeshInstance3D
var blockerMat
var blockerAlpha


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	worldNode = get_node("/root/Root/World")
	worldEnvNode = worldNode.get_node("WorldEnvironment")
	currentEnvironment = worldNode.get_node("ENVIRONMENT")
	
	user = get_node("/root/Root/XROrigin3D")
	userBody = user.get_node("PlayerBody")
	transitionBlocker = user.get_node("XRCamera3D/TransitionBlocker")
	blockerMat = transitionBlocker.get_active_material(0)
	blockerAlpha = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if envTransition and blockerAlpha < 255:
		blockerAlpha += 1
		blockerMat.albedo_color = Color.from_rgba8(0, 0, 0, blockerAlpha)
		
		if blockerAlpha == 255:
			updateEnvironment(environmentIndex)
			
	if !envTransition and blockerAlpha > 0:
		blockerAlpha -= 1
		blockerMat.albedo_color = Color.from_rgba8(0, 0, 0, blockerAlpha)




func startEnvironmentTransition(envNum):
	envTransition = true
	environmentIndex = envNum




func updateEnvironment(envNum):
	var env = worldEnvNode.environment
	var sky = env.sky
	var sky_material = sky.sky_material
	
	user.position = Vector3(0, 0.150, 0.605)
	
	if envNum == 0:
		targetEnvironment = load("res://Environments/OfficeNew.tscn")
		sky_material.panorama = citySky
	
	elif envNum == 1:
		targetEnvironment = load("res://Environments/Garden.tscn")
		sky_material.panorama = blueSky
		
	elif envNum == 2:
		targetEnvironment = load("res://Environments/Temple.tscn")
		sky_material.panorama = blueSky
		pass
		
	else:
		targetEnvironment = load("res://Environments/Lab.tscn")
		sky_material.panorama = citySky
		
	var newEnvironment = targetEnvironment.instantiate()
	currentEnvironment.queue_free()
	currentEnvironment = newEnvironment
	
	worldNode.add_child(currentEnvironment)
	
	user.position = Vector3(0, 0.150, 0.605)
	
	envTransition = false
		
	
