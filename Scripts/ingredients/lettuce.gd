extends Ingredient

@export var default_visual: MeshInstance3D
@export var chopped_visual: MeshInstance3D
@export var overcooked_visual: MeshInstance3D

func _ready() -> void:
	isChoppable = true
	isCookable = true
	cook_time = 5.0
	overcook_time = 0.0  # unused, cook() gos straight to overcooked
	currentState = State.raw

	default_visual.visible = true
	chopped_visual.visible = false
	overcooked_visual.visible = false

func update_visual() -> void:
	default_visual.visible = currentState == State.raw
	chopped_visual.visible = currentState == State.chopped
	overcooked_visual.visible = currentState == State.overcooked

func chop() -> void:
	if currentState != State.raw:
		return
	currentState = State.chopped
	update_visual()

func cook() -> void:
	# Lettuce skips cooked and goes straight to overcooked.
	super.overcook()
	update_visual()

func overcook() -> void:
	pass  # cook() already does ts
	
