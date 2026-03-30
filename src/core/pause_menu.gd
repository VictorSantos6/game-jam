extends CanvasLayer

@onready var resume_button: Button = $PanelContainer/MarginContainer/VBoxContainer/ResumeButton
@onready var main_menu_button: Button = $PanelContainer/MarginContainer/VBoxContainer/MainMenuButton

const MAIN_MENU_PATH := "res://scenes/main_menu.tscn"


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(_on_resume_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	resume_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_P:
			_on_resume_pressed()


func _on_resume_pressed() -> void:
	get_tree().paused = false
	queue_free()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
