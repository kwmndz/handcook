extends Ingredient

@export var default_visual: MeshInstance3D
@export var chopped_visual: MeshInstance3D

func _ready() -> void:
	isChoppable = true
	isCookable = false
	currentState = State.raw
	
	default_visual.visible = true
	chopped_visual.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_visual():
	default_visual.visible = currentState == State.raw
	chopped_visual.visible = currentState == State.chopped

func chop() -> void: 
	currentState = State.chopped
	update_visual()
	
