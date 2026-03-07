extends Node3D

@onready var hand = $MouseHand
#@onready var ingredient = $Lettuce

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hand.on_action.connect(_on_hand_action)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_hand_action(ingredient: Ingredient):
	if ingredient == null:
		return

	if ingredient.has_method("chop"):
		print("ingredient: ", ingredient)
		ingredient.chop()
