class_name Tool

extends Node3D

@export var rigid_body: RigidBody3D
@export var hold_offset_position: Vector3 = Vector3.ZERO
@export var hold_offset_rotation: Vector3 = Vector3.ZERO
@export var hit_area: Area3D

var holder: Node3D = null
var is_held: bool = false

## Traverses up the scene tree from the given node to find a Tool.
## Use this when collision/area callbacks give you a RigidBody3D or Area3D
## that is a descendant of a Tool.
static func find_from_node(node: Node) -> Tool:
	var current := node
	while current:
		if current is Tool:
			return current as Tool
		current = current.get_parent()
	return null

func _ready() -> void:
	if rigid_body == null:
		rigid_body = _find_rigid_body()
	if hit_area == null and rigid_body:
		hit_area = rigid_body.get_node_or_null("Area3D")

	if hit_area:
		hit_area.body_entered.connect(_on_hit_body_entered)
		hit_area.area_entered.connect(_on_hit_area_entered)

func _find_rigid_body() -> RigidBody3D:
	for child in get_children():
		if child is RigidBody3D:
			return child as RigidBody3D
	return null

func _on_hit_body_entered(body: Node) -> void:
	var ingredient := Ingredient.find_from_node(body)
	if ingredient:
		_on_hit_ingredient(ingredient)

func _on_hit_area_entered(area: Area3D) -> void:
	var ingredient := Ingredient.find_from_node(area)
	if ingredient:
		_on_hit_ingredient(ingredient)

# Override this in subclasses
func _on_hit_ingredient(ingredient: Ingredient) -> void:
	pass

# Override in subclasses if needed
func disable_physics() -> void:
	if rigid_body:
		rigid_body.freeze = true

func enable_physics() -> void:
	if rigid_body:
		rigid_body.freeze = false

func pick_up(new_holder: Node3D, hold_point: Node3D) -> void:
	holder = new_holder
	is_held = true

	disable_physics()
	if rigid_body:
		rigid_body.linear_velocity = Vector3.ZERO
		rigid_body.angular_velocity = Vector3.ZERO

	if get_parent():
		get_parent().remove_child(self)
	hold_point.add_child(self)
	position = hold_offset_position
	rotation = Vector3(
		deg_to_rad(hold_offset_rotation.x),
		deg_to_rad(hold_offset_rotation.y),
		deg_to_rad(hold_offset_rotation.z)
	)

func drop(drop_parent: Node) -> void:
	if not is_held:
		return

	var world_transform_cache := global_transform

	if get_parent():
		get_parent().remove_child(self)

	drop_parent.add_child(self)
	global_transform = world_transform_cache

	holder = null
	is_held = false
	enable_physics()

# Override in subclasses
func use(target = null) -> void:
	pass
