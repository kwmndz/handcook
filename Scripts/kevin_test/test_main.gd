extends Node3D

@onready var hand = $MouseHand
@onready var menu = $CanvasLayer/menu
@onready var _workstation: Node3D = $Workstation

# 1/2 the size of the workstation is 1.0, 0.75
# with with local coords of workstation
@export var spawn_extents: Vector2 = Vector2(0.85, 0.60)
# local y of worstation
@export var spawn_height: float = 0.9

func _ready() -> void:
	hand.on_action.connect(_on_hand_action)
	menu.spawn_requested.connect(_on_spawn_requested)
	menu.menu_opened.connect(func(): hand.set_process_input(false))
	menu.menu_closed.connect(func(): hand.set_process_input(true))

func _on_hand_action(ingredient: Ingredient):
	if ingredient == null:
		return
	if ingredient.has_method("chop"):
		ingredient.chop()

func _random_spawn_position() -> Vector3:
	var local := Vector3(
		randf_range(-spawn_extents.x, spawn_extents.x),
		spawn_height,
		randf_range(-spawn_extents.y, spawn_extents.y)
	)
	return _workstation.to_global(local)

func _on_spawn_requested(scene: PackedScene, _position: Vector3, rotation_degrees: Vector3, scale_vec: Vector3) -> void:
	var instance = scene.instantiate()
	add_child(instance)
	instance.global_position = _random_spawn_position()
	instance.rotation_degrees = rotation_degrees
	instance.scale = scale_vec
