class_name Patty
extends Ingredient

@export var raw_visual: MeshInstance3D
@export var cooked_visual: MeshInstance3D
@export var overcooked_visual: MeshInstance3D

func _ready() -> void:
	super._ready()
	isChoppable = false
	isCookable = true
	cook_time = 8.0
	overcook_time = 5.0
	currentState = State.raw

	raw_visual.visible = true
	cooked_visual.visible = false
	overcooked_visual.visible = false

func update_visual() -> void:
	raw_visual.visible = currentState == State.raw
	cooked_visual.visible = currentState == State.cooked
	overcooked_visual.visible = currentState == State.overcooked

func cook() -> void:
	if currentState != State.raw:
		return
	_play_smoke_and_change(func():
		super.cook()
		update_visual()
	)

func overcook() -> void:
	if currentState != State.cooked:
		return
	_play_smoke_and_change(func():
		super.overcook()
		update_visual()
	)
