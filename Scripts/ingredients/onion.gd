extends Ingredient

@export var raw_visual: MeshInstance3D
@export var chopped_visual: MeshInstance3D

@export var raw_collision: CollisionShape3D
@export var chopped_collision: CollisionShape3D

func _ready() -> void:
	super._ready()
	isChoppable = true
	isCookable = false
	currentState = State.raw

	raw_visual.visible = true
	chopped_visual.visible = false

	raw_collision.disabled = false
	chopped_collision.disabled = true

func update_visual() -> void:
	raw_visual.visible = currentState == State.raw
	chopped_visual.visible = currentState == State.chopped

	raw_collision.disabled = currentState != State.raw
	chopped_collision.disabled = currentState != State.chopped

func chop() -> void:
	if currentState != State.raw:
		return
	_play_smoke_and_change(func():
		currentState = State.chopped
		update_visual()
	)
