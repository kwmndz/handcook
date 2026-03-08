extends Control

signal spawn_requested(scene: PackedScene, position: Vector3, \
	rotation_degrees: Vector3, scale_vec: Vector3)
signal menu_opened
signal menu_closed

@onready var _grid: GridContainer = $VBoxContainer/Control/GridContainer
@onready var _back_btn: Button = $VBoxContainer/HBoxContainer/Button
@onready var _reset_btn: Button = $VBoxContainer/HBoxContainer/Button2
@onready var _quit_btn: Button = $VBoxContainer/HBoxContainer/Button3

func _ready() -> void:
	hide()
	_back_btn.pressed.connect(_on_back)
	_reset_btn.pressed.connect(_on_reset)
	_quit_btn.pressed.connect(_on_quit)

	for child in _grid.get_children():
		if child is SpawnButton:
			child.spawn_pressed.connect(_on_spawn_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if visible:
			_close()
		else:
			_open()
		get_viewport().set_input_as_handled()


func _open() -> void:
	show()
	menu_opened.emit()

func _close() -> void:
	hide()
	menu_closed.emit()

func _on_back() -> void:
	_close()

func _on_reset() -> void:
	print("reset")

func _on_quit() -> void:
	get_tree().quit()

func _on_spawn_pressed(scene: PackedScene, position: Vector3, rotation_degrees: Vector3, scale_vec: Vector3) -> void:
	spawn_requested.emit(scene, position, rotation_degrees, scale_vec)
	_close()
