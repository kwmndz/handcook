class_name Ingredient

extends Node3D

enum State {raw, chopped, cooked, overcooked}

@export var isChoppable: bool = false
@export var isCookable: bool = false
@export var currentState: State = State.raw
@export var amtStates: int = 4

# Seconds on the stove until cooked.
@export var cook_time: float = 10.0
# Seconds after cooked until overcooked.
@export var overcook_time: float = 5.0

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
