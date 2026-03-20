extends Node3D

var slots ##List variable to store the shortcut slots.


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	slots = []
	
	for i in range(0, 4):
		var tempSlot = get_node("Slot" + str(i+1))
		slots.append(tempSlot)
		
	print("Slots: ", slots)




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func addShortcut(targetSlot, commandString):
	print("Add shortcut: ", targetSlot, commandString)




func removeShortcut(targetSlot):
	print("Remove shortcut: ", targetSlot)
