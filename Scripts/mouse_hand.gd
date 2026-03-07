extends Node3D

signal on_hover(ingredient: Ingredient)
signal on_action(ingredient: Ingredient)

@export var detector: Area3D
@export var camera: Camera3D
@export var depth_sensitivity := 0.03
@export var move_speed := 12.0
@export var min_depth := 0
@export var max_depth := 10.0

var depth := 4.0
var frozen_mouse_pos := Vector2.ZERO
var hovered_ingredient: Ingredient = null


func _ready() -> void:
	if detector == null:
		detector = $Area3D

	detector.body_entered.connect(_on_body_entered)
	detector.body_exited.connect(_on_body_exited)
	detector.area_entered.connect(_on_area_entered)
	detector.area_exited.connect(_on_area_exited)
	
	if camera == null:
		camera = get_viewport().get_camera_3d()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("depth_mod"):
		frozen_mouse_pos = get_viewport().get_mouse_position()

	if event is InputEventMouseMotion and Input.is_action_pressed("depth_mod"):
		depth -= event.relative.y * depth_sensitivity
		depth = clamp(depth, min_depth, max_depth)
	
	if event.is_action_pressed("pinch"):
		on_action.emit(hovered_ingredient)

func _process(delta: float) -> void:
	if camera == null:
		return

	var mouse_pos: Vector2
	if Input.is_action_pressed("depth_mod"):
		mouse_pos = frozen_mouse_pos
	else:
		mouse_pos = get_viewport().get_mouse_position()

	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)

	var target_pos = ray_origin + ray_dir * depth
	global_position = global_position.lerp(target_pos, delta * move_speed)

func _on_body_entered(body: Node) -> void:
	if body is Ingredient:
		hovered_ingredient = body
		on_hover.emit(hovered_ingredient)

func _on_body_exited(body: Node) -> void:
	if body == hovered_ingredient:
		hovered_ingredient = null
		on_hover.emit(null)

func _on_area_entered(area: Area3D) -> void:
	var parent = area.get_parent()
	if parent is Ingredient:
		hovered_ingredient = parent
		on_hover.emit(hovered_ingredient)

func _on_area_exited(area: Area3D) -> void:
	var parent = area.get_parent()
	if parent == hovered_ingredient:
		hovered_ingredient = null
		on_hover.emit(null)
