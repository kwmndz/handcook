extends Node3D

@onready var menu = $CanvasLayer/menu
@onready var _workstation: Node3D = $kitchentop

# for spawning the objects randomly
@export var spawn_extents: Vector2 = Vector2(2, 3)
@export var spawn_height: float = 4.5

func _ready() -> void:
	menu.spawn_requested.connect(_on_spawn_requested)

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
