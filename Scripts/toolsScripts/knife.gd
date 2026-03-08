extends Tool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	#hold_offset_rotation = Vector3(90,-90,90)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func use(target = null) -> void:
	if target and target.has_method("chop"):
		target.chop()

func _on_hit_ingredient(ingredient: Ingredient) -> void:
	if ingredient.has_method("chop"):
		ingredient.chop()
