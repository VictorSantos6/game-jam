extends Control

const LEVEL_SCENES: Array[String] = [
	"res://scenes/levels/introduction.tscn",
	"res://scenes/levels/tutorial.tscn",
	"res://scenes/levels/level1.tscn",
	"res://scenes/levels/level2.tscn",
	"res://scenes/levels/level3.tscn",
]

@onready var level_buttons: Array[Button] = [
	$MarginContainer/Panel/Content/VBox/Buttons/IntroLevelButton,
	$MarginContainer/Panel/Content/VBox/Buttons/TutorialLevelButton,
	$MarginContainer/Panel/Content/VBox/Buttons/Level1Button,
	$MarginContainer/Panel/Content/VBox/Buttons/Level2Button,
	$MarginContainer/Panel/Content/VBox/Buttons/Level3Button,
]
@onready var status_label: Label = $MarginContainer/Panel/Content/VBox/Status


func _ready() -> void:
	for index in level_buttons.size():
		level_buttons[index].pressed.connect(_on_level_button_pressed.bind(index))

	level_buttons[0].grab_focus()
	status_label.text = "Select a level to start."


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return

	if not event.pressed or event.echo:
		return

	match event.keycode:
		KEY_I:
			_load_level(0)
		KEY_T:
			_load_level(1)
		KEY_1:
			_load_level(2)
		KEY_2:
			_load_level(3)
		KEY_3:
			_load_level(4)


func _on_level_button_pressed(level_index: int) -> void:
	_load_level(level_index)


func _load_level(level_index: int) -> void:
	if level_index < 0 or level_index >= LEVEL_SCENES.size():
		status_label.text = "That level is not available."
		return

	var scene_path: String = LEVEL_SCENES[level_index]
	status_label.text = "Loading Level %d..." % (level_index + 1)
	var error := get_tree().change_scene_to_file(scene_path)
	if error != OK:
		status_label.text = "Unable to load Level %d." % (level_index + 1)
