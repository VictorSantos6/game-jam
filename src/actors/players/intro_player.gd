extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 130.0
const PAUSE_MENU_PATH := "res://scenes/pause_menu.tscn"

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	_update_animation(direction)

	if direction != 0:
		sprite.flip_h = direction < 0


func _update_animation(direction: float) -> void:
	if direction != 0.0:
		_play_first_available(["running", "run"])
	else:
		_play_first_available(["idle"])


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_P:
			_show_pause_menu()


func _show_pause_menu() -> void:
	get_tree().paused = true
	var pause_menu = load(PAUSE_MENU_PATH).instantiate()
	add_child(pause_menu)


func _play_first_available(candidates: Array[String]) -> void:
	if sprite == null or sprite.sprite_frames == null:
		return

	for animation_name in candidates:
		if sprite.sprite_frames.has_animation(animation_name):
			if sprite.animation != animation_name:
				sprite.play(animation_name)
			elif not sprite.is_playing():
				sprite.play()
			return
