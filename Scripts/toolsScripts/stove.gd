extends CSGBox3D

# Ingredients physically on stove currently
var _on_stove: Dictionary = {}
# maps Ingredient -> Timer for the active cooking/overcooking timer
var _timers: Dictionary = {}

func _ready() -> void:
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	var ingredient := Ingredient.find_from_node(body)
	if not ingredient or not ingredient.isCookable:
		return
	_on_stove[ingredient] = true
	if not _timers.has(ingredient):
		if (ingredient.currentState == ingredient.State.cooked):
			_start_timer(ingredient, ingredient.overcook_time, "overcooking")
		elif (ingredient.currentState != ingredient.State.overcooked):
			_start_timer(ingredient, ingredient.cook_time, "cooking")

func _on_body_exited(body: Node3D) -> void:
	var ingredient := Ingredient.find_from_node(body)
	if not ingredient:
		return
	_on_stove.erase(ingredient)
	if _timers.has(ingredient):
		_timers[ingredient].queue_free()
		_timers.erase(ingredient)

func _start_timer(ingredient: Ingredient, wait: float, stage: String) -> void:
	var timer := Timer.new()
	timer.wait_time = wait
	timer.one_shot = true
	timer.timeout.connect(_on_timer_done.bind(ingredient, stage))
	add_child(timer)
	timer.start()
	_timers[ingredient] = timer

func _on_timer_done(ingredient: Ingredient, stage: String) -> void:
	_timers.erase(ingredient)

	if stage == "cooking":
		ingredient.cook()
		if _on_stove.has(ingredient):
			_start_timer(ingredient, ingredient.overcook_time, "overcooking")
	elif stage == "overcooking":
		ingredient.overcook()
