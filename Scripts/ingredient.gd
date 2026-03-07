class_name Ingredient

extends Node3D

enum State {raw, chopped, cooked, overcooked}

@export var isChoppable: bool = false
@export var isCookable: bool = false
@export var currentState: State = State.raw
@export var amtStates: int = 4

func updateState() -> void:
	currentState = (currentState + 1) % amtStates
