class_name Ingredient

extends Node3D

enum State {raw, chopped, cooked, overcooked}

@export var rigid_body: RigidBody3D
@export var hold_offset_position: Vector3 = Vector3.ZERO
@export var hold_offset_rotation: Vector3 = Vector3.ZERO
@export var smoke_particles: GPUParticles3D

@export var isChoppable: bool = false
@export var isCookable: bool = false
@export var currentState: State = State.raw
@export var amtStates: int = 4

# Seconds on the stove until cooked.
@export var cook_time: float = 10.0
# Seconds after cooked until overcooked.
@export var overcook_time: float = 5.0

var holder: Node3D = null
var is_held: bool = false
var _is_changing: bool = false

# goes up the scene tree from the given node to find an Ingredient
# gets used when the collision callbacks give the collision body
# that is a child of an ingredient
static func find_from_node(node: Node) -> Ingredient:
	var current := node
	while current:
		if current is Ingredient:
			return current as Ingredient
		current = current.get_parent()
	return null

func _ready() -> void:
	if rigid_body == null: # auto find rigid body
		for child in get_children():
			if child is RigidBody3D:
				rigid_body = child
				break

# Plays the smoke burst then calls callback to
# do the actual state swap
func _play_smoke_and_change(callback: Callable) -> void:
	# make sure its not called while alr playing
	if _is_changing:
		return
	_is_changing = true

	if smoke_particles:
		smoke_particles.restart()
		smoke_particles.emitting = true
		# wait until abt end animation
		await get_tree().create_timer(smoke_particles.lifetime * 0.4).timeout

	callback.call()
	_is_changing = false

func disable_physics() -> void:
	if rigid_body:
		rigid_body.freeze = true

func enable_physics() -> void:
	if rigid_body:
		rigid_body.freeze = false
		rigid_body.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC

func pick_up(new_holder: Node3D, hold_point: Node3D) -> void:
	holder = new_holder
	is_held = true
	var bscale := scale

	disable_physics()
	if rigid_body:
		rigid_body.linear_velocity = Vector3.ZERO
		rigid_body.angular_velocity = Vector3.ZERO
		rigid_body.transform = Transform3D.IDENTITY

	if get_parent():
		reparent(hold_point, false)

	var rot_rad := Vector3(
		deg_to_rad(hold_offset_rotation.x),
		deg_to_rad(hold_offset_rotation.y),
		deg_to_rad(hold_offset_rotation.z)
	)
	transform = Transform3D(Basis.from_euler(rot_rad), hold_offset_position)
	scale = bscale

func drop(drop_parent: Node) -> void:
	if not is_held:
		return

	if get_parent():
		reparent(drop_parent, true)

	holder = null
	is_held = false
	enable_physics()

func updateState() -> void:
	currentState = (currentState + 1) % amtStates

# Override in subclasses to handle visuals.
func cook() -> void:
	if currentState == State.cooked or currentState == State.overcooked:
		return
	currentState = State.cooked

func overcook() -> void:
	if currentState == State.overcooked:
		return
	currentState = State.overcooked
