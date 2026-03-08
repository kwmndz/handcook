extends Node3D

# area where items get deleted
@export var bottom_area: Area3D

func _ready() -> void:
	if bottom_area:
		bottom_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	var target: Node = Ingredient.find_from_node(body)
	if not target:
		target = Tool.find_from_node(body)
	if not target:
		target = body
	target.queue_free()
	print("deleted", target)
