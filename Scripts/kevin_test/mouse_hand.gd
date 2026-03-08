extends Node3D

signal on_hover(ingredient: Ingredient)
signal on_action(ingredient: Ingredient)

@export var scene: Node3D
@export var detector: Area3D
@export var camera: Camera3D
@export var bound: Area3D
@export var hold_point: Node3D
@export var depth_sensitivity := 0.03
@export var move_speed := 12.0
@export var min_depth := 0
@export var max_depth := 10.0


var held_tool: Tool = null
var held_ingredient: Ingredient = null
var depth := 4.0
var frozen_mouse_pos := Vector2.ZERO
var hovered_ingredient: Ingredient = null
var hovered_tool: Tool = null

# returns the target coordinates
@onready var collision_shape: CollisionShape3D = $"../Bound/Collider"
@onready var box := collision_shape.shape as BoxShape3D


func place_in_box(normalized: Vector3) -> Vector3:
	if box == null:
		push_error("CollisionShape3D does not use a BoxShape3D")
	var local_pos = (normalized - Vector3(0.5, 0.5, 0.5)) * box.size
	var world_pos = collision_shape.global_transform * local_pos
	return world_pos


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
	
func pick_up_ingredient(ingredient: Ingredient) -> void:
	if held_ingredient != null:
		return

	held_ingredient = ingredient
	ingredient.pick_up(self, hold_point)

func drop_ingredient(drop_parent: Node) -> void:
	if held_ingredient == null:
		return

	held_ingredient.drop(drop_parent)
	held_ingredient = null


var box_pos: Vector3
var half_height: float
var min_y: float
var max_y: float

func _ready() -> void:
	# calc args
	box_pos = collision_shape.global_position
	half_height = box.size.y / 2.0
	min_y = box_pos.y - half_height
	max_y = box_pos.y + half_height
	
	if detector == null:
		detector = $Area3D
	detector.area_entered.connect(_on_area_entered)
	detector.area_exited.connect(_on_area_exited)
	if camera == null:
		camera = get_viewport().get_camera_3d()


enum YState { DOWN, NEUTRAL, UP }
var y_state := YState.NEUTRAL
var up_enter := 0.9
var up_exit := 0.85
var down_enter := 0.15
var down_exit := 0.2
var adjust := .04
func calculate_y_state(y):
	match y_state:
		YState.NEUTRAL:
			if y > up_enter:
				y_state = YState.UP
			elif y < down_enter:
				y_state = YState.DOWN
		YState.UP:
			if y < up_exit:
				y_state = YState.NEUTRAL
		YState.DOWN:
			if y > down_exit:
				y_state = YState.NEUTRAL


func _process(delta: float) -> void:
	if $Server.hand_type == "LEFT":
		scale.x = -1 
	else:
		scale.x = 1
	
	if $Server.cur_gesture == "FIST":
		$open.visible = false
		$fist.visible = true
	else:
		$open.visible = true
		$fist.visible = false
	
	if camera == null:
		return
	# process the gesture
	if $Server.cur_gesture == "FIST":
		if (hovered_tool):
			pick_up_tool(hovered_tool)
		if (hovered_ingredient):
			pick_up_ingredient(hovered_ingredient)
	if $Server.cur_gesture == "OPEN":
		if (held_tool != null):
			drop_tool(scene)
		if held_ingredient != null:
			drop_ingredient(scene)
	
	# move the controller
	var target_pos = place_in_box($Server.hand_rel_pos)
	
	# move y + clamp
	calculate_y_state($Server.hand_rel_pos.y)
	match y_state:
		YState.NEUTRAL:
			target_pos.y = position.y
		YState.DOWN:
			target_pos.y = position.y - adjust
		YState.UP:
			target_pos.y = position.y + adjust
	target_pos.y = clamp(target_pos.y, min_y, max_y)
	
	# apply the movement lerped
	position = position.lerp(target_pos, delta * move_speed)
	
	# debug statements
	#print("GOT: ", $Server.hand_rel_pos)
	#print("TARGET: ", target_pos)
	#print("POS: ", position)
	#print()

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
