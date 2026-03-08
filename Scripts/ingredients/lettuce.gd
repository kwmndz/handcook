class_name Lettuce
extends Ingredient

@export var default_visual: MeshInstance3D
@export var chopped_visual: MeshInstance3D
@export var overcooked_visual: MeshInstance3D
@export var overcooked_chopped_visual: MeshInstance3D

@export var default_collision: CollisionShape3D
@export var chopped_collision: CollisionShape3D

func _ready() -> void:
	super._ready()
	isChoppable = true
	isCookable = true
	cook_time = 5.0
	overcook_time = 0.0  # unused, cook() goes straight to overcooked
	currentState = State.raw

	default_visual.visible = true
	chopped_visual.visible = false
	overcooked_visual.visible = false

	default_collision.disabled = false
	chopped_collision.disabled = true

func update_visual() -> void:
	default_visual.visible = currentState == State.raw
	chopped_visual.visible = currentState == State.chopped
	
	if default_collision.disabled == true:
		overcooked_chopped_visual.visible = currentState == State.overcooked
	else:
		overcooked_visual.visible = currentState == State.overcooked
	
	if currentState == State.chopped:
		default_collision.disabled = currentState != State.raw
		chopped_collision.disabled = currentState == State.raw

func chop() -> void:
	if currentState != State.raw:
		return
	# for the animation
	_play_smoke_and_change(func():
		currentState = State.chopped
		update_visual()
	)

func cook() -> void:
	# Lettuce skips cooked and goes straight to overcooked.
	_play_smoke_and_change(func():
		super.overcook()
		update_visual()
	)

func overcook() -> void:
	pass  # cook() already does ts
	
