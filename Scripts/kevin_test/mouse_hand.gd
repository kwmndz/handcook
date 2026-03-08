extends Node3D

signal on_hover(ingredient: Ingredient)
signal on_action(ingredient: Ingredient)

@export var scene: Node3D
@export var detector: Area3D
@export var camera: Camera3D
@export var hold_point: Node3D
@export var depth_sensitivity := 0.03
@export var move_speed := 12.0
@export var min_depth := 0
@export var max_depth := 10.0

var held_tool: Tool = null
var depth := 4.0
var frozen_mouse_pos := Vector2.ZERO
var hovered_ingredient: Ingredient = null
var hovered_tool: Tool = null

# Tool interaction helper functions
func pick_up_tool(tool: Tool) -> void:
	if held_tool != null:
		return

	held_tool = tool
	tool.pick_up(self, hold_point)

func drop_tool(drop_parent: Node) -> void:
	if held_tool == null:
		return

	held_tool.drop(drop_parent)
	held_tool = null

func _ready() -> void:
	if detector == null:
		detector = $Area3D
	
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
	if  event.is_action_pressed("grab"):
		if (hovered_tool):
			pick_up_tool(hovered_tool)
	if event.is_action_released("grab"):
		drop_tool(scene)

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

# Collision detection for interacting with objects
func _on_area_entered(area: Area3D) -> void:
	var ingredient = Ingredient.find_from_node(area)
	if ingredient:
		hovered_ingredient = ingredient
		on_hover.emit(hovered_ingredient)
	var tool = Tool.find_from_node(area)
	if tool:
		hovered_tool = tool

func _on_area_exited(area: Area3D) -> void:
	var ingredient = Ingredient.find_from_node(area)
	if ingredient == hovered_ingredient:
		hovered_ingredient = null
		on_hover.emit(null)
	var tool = Tool.find_from_node(area)
	if tool == hovered_tool:
		hovered_tool = null

# maybe use this function (prob not)
func use_tool(target = null) -> void:
	if held_tool != null:
		held_tool.use(target)
