class_name SpawnButton
extends Button

@export var scene_to_spawn: PackedScene
@export var spawn_position: Vector3 = Vector3.ZERO
@export var spawn_rotation_degrees: Vector3 = Vector3.ZERO
@export var spawn_scale: Vector3 = Vector3.ONE

signal spawn_pressed(scene: PackedScene, position: Vector3, rotation_degrees: Vector3, scale_vec: Vector3)

func _ready() -> void:
	pressed.connect(_on_pressed)
	disabled = scene_to_spawn == null

func _on_pressed() -> void:
	spawn_pressed.emit(scene_to_spawn, spawn_position, spawn_rotation_degrees, spawn_scale)
