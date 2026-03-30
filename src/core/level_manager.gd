extends Control

const LEVEL_SCENES: Array[String] = [
	"res://scenes/levels/introduction.tscn",
	"res://scenes/levels/tutorial.tscn",
	"res://scenes/levels/level1.tscn",
	"res://scenes/levels/level2.tscn",
	"res://scenes/levels/ending.tscn",
]


@onready var level_buttons: Array[Button] = [
	$MarginContainer/Panel/Content/VBox/Buttons/IntroLevelButton,
	$MarginContainer/Panel/Content/VBox/Buttons/TutorialLevelButton,
	$MarginContainer/Panel/Content/VBox/Buttons/Level1Button,
	$MarginContainer/Panel/Content/VBox/Buttons/Level2Button,
	$MarginContainer/Panel/Content/VBox/Buttons/EndingButton,
]
var locked_dialog: AcceptDialog = null
@onready var status_label: Label = $MarginContainer/Panel/Content/VBox/Status


func _ready() -> void:
	# create a reusable dialog for locked-level messages
	locked_dialog = AcceptDialog.new()
	add_child(locked_dialog)

	for index in level_buttons.size():
		var btn := level_buttons[index]
		var scene_path := LEVEL_SCENES[index]
		if Progression.is_unlocked(scene_path):
			btn.pressed.connect(_on_level_button_pressed.bind(index))
		else:
			# keep the button interactive so clicking shows why it's locked
			btn.pressed.connect(_on_locked_button_pressed.bind(index))

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
			_handle_level_request(2)
		KEY_2:
			_handle_level_request(3)
		KEY_E:
			_handle_level_request(4)


func _on_level_button_pressed(level_index: int) -> void:
	_load_level(level_index)

func _on_locked_button_pressed(level_index: int) -> void:
	var scene_path := LEVEL_SCENES[level_index]
	_show_locked_message(scene_path)

func _handle_level_request(level_index: int) -> void:
	var scene_path := LEVEL_SCENES[level_index]
	if Progression.is_unlocked(scene_path):
		_load_level(level_index)
	else:
		_show_locked_message(scene_path)

func _show_locked_message(scene_path: String) -> void:
	var filename := scene_path.get_file()
	locked_dialog.dialog_text = "%s is locked. Complete previous levels to unlock it." % filename
	locked_dialog.popup_centered()


func _load_level(level_index: int) -> void:
	if level_index < 0 or level_index >= LEVEL_SCENES.size():
		status_label.text = "That level is not available."
		return

	var scene_path: String = LEVEL_SCENES[level_index]
	status_label.text = "Loading Level %d..." % (level_index + 1)
	var error := get_tree().change_scene_to_file(scene_path)
	if error != OK:
		status_label.text = "Unable to load Level %d." % (level_index + 1)
