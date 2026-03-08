class_name Tool

extends RigidBody3D

@export var hold_offset_position: Vector3 = Vector3.ZERO
@export var hold_offset_rotation: Vector3 = Vector3.ZERO

var holder: Node3D = null
var is_held: bool = false

# funcs to be overwritten
func disable_physics() -> void:
	freeze = true
func enable_physics() -> void:
	freeze = false
	
func pick_up(new_holder: Node3D, hold_point: Node3D) -> void:
	holder = new_holder
	is_held = true

	disable_physics()
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

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
	
# to be overwritten
func use(target = null) -> void:
	pass
