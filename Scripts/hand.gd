extends Node3D

signal on_hover(name: String)
signal on_action(name: String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pinch"):
		on_action.emit("test")
	
	
	
func _on_on_action(name: String):
	print(name)
	
	
