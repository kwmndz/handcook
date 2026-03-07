extends Node3D

@onready var hand = $hand_test/Hand
@onready var ingredient = $Lettuce

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hand.on_action.connect(_on_hand_action)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_hand_action(name: String):
	if ingredient and ingredient.has_method("chop"):
		ingredient.chop()
