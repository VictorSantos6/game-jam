extends Control

class_name ConnectionComplete

const MAIN_MENU_PATH := "res://scenes/main_menu.tscn"
const AUTO_ADVANCE_DELAY := 1.8

static var pending_message := "Connection completed"
static var pending_next_scene := MAIN_MENU_PATH

@onready var message_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBox/Message
@onready var hint_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBox/Hint

var is_transitioning := false


func _ready() -> void:
	message_label.text = pending_message
	hint_label.text = "Loading next level..."
	await get_tree().create_timer(AUTO_ADVANCE_DELAY).timeout
	_go_next_scene()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE or event.keycode == KEY_ESCAPE:
			_go_next_scene()


func _go_next_scene() -> void:
	if is_transitioning:
		return
	is_transitioning = true

	var target_scene := pending_next_scene
	if target_scene.is_empty():
		target_scene = MAIN_MENU_PATH

	# Ensure the progression state includes the next scene (idempotent)
	if target_scene != null and target_scene != "":
		if Progression != null:
			Progression.unlock_scene(target_scene)

	var error := get_tree().change_scene_to_file(target_scene)
	if error != OK:
		get_tree().change_scene_to_file(MAIN_MENU_PATH)
