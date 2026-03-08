class_name CreationBin
extends Node3D

@export var area_3d: Area3D
@export var confetti: GPUParticles3D

# type_id -> Array of Ingredient nodes currently inside
var _inside: Dictionary = {}
var _is_making: bool = false

func _ready() -> void:
	area_3d.body_entered.connect(_on_body_entered)
	area_3d.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	var ingredient := Ingredient.find_from_node(body)
	if ingredient == null:
		return
	var type_id := _get_type_id(ingredient)
	if type_id.is_empty():
		return

	if not _inside.has(type_id):
		_inside[type_id] = []
	_inside[type_id].append(ingredient)

	_check_complete()

func _on_body_exited(body: Node3D) -> void:
	var ingredient := Ingredient.find_from_node(body)
	if ingredient == null:
		return
	var type_id := _get_type_id(ingredient)
	if type_id.is_empty() or not _inside.has(type_id):
		return

	_inside[type_id].erase(ingredient)
	if _inside[type_id].is_empty():
		_inside.erase(type_id)

func _get_type_id(ingredient: Ingredient) -> String:
	if ingredient is Lettuce:
		return "lettuce"
	if ingredient is Onion:
		return "onion"
	if ingredient is Patty:
		return "patty"
	if ingredient is Bun:
		return "bun"
	if ingredient is BunTop:
		return "bun_top"
	return ""

func _check_complete() -> void:
	if _is_making:
		return
	var required := ["lettuce", "onion", "patty", "bun", "bun_top"]
	for id in required:
		if not _inside.has(id):
			return
	_make_burger()

func _make_burger() -> void:
	_is_making = true

	# Grab one of each required ingredient to delete
	var to_delete: Array = []
	for id in ["lettuce", "onion", "patty", "bun", "bun_top"]:
		to_delete.append(_inside[id][0])

	_inside.clear()

	for ingredient in to_delete:
		ingredient.queue_free()

	confetti.restart()
	confetti.emitting = true

	# Wait for particle burst to finish before allowing another burger
	await get_tree().create_timer(confetti.lifetime).timeout
	_is_making = false
