class_name Bun
extends Ingredient

func _ready() -> void:
	super._ready()
	isChoppable = false
	isCookable = false
	currentState = State.raw
