class_name Ingredient

extends Node3D

enum State {raw, chopped, cooked, overcooked}

@export var isChoppable: bool = false
@export var isCookable: bool = false
@export var currentState: State = State.raw
@export var amtStates: int = 4

## Traverses up the scene tree from the given node to find an Ingredient.
## Use this when collision/area callbacks give you a RigidBody3D or Area3D
## that is a descendant of an Ingredient.
static func find_from_node(node: Node) -> Ingredient:
	var current := node
	while current:
		if current is Ingredient:
			return current as Ingredient
		current = current.get_parent()
	return null

func updateState() -> void:
	currentState = (currentState + 1) % amtStates
