extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hearts_label: Label = $CanvasLayer/HUD/HeartsLabel
@onready var game_over_label: Label = $CanvasLayer/HUD/GameOverLabel

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const STARTING_LIVES := 3
const MAIN_MENU_PATH := "res://scenes/main_menu.tscn"

const WALL_JUMP_FORCE = Vector2(300, -400)

static var remaining_lives := STARTING_LIVES

var jump_count := 0
var max_jumps := 2
var is_dead := false

enum State {
	IDLE,
	RUN,
	JUMP,
	FALL,
	DOUBLE_JUMP,
	WALL_JUMP,
	HIT
}

var state: State = State.IDLE


func _ready() -> void:
	update_life_ui()
	game_over_label.visible = false

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Reset jumps on floor
	if is_on_floor():
		jump_count = 0

	var direction = Input.get_axis("left", "right")

	# Horizontal movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Jump + Wall Jump
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			jump_count = 1
			change_state(State.JUMP)

		elif is_on_wall():
			var wall_dir = get_wall_normal().x
			velocity = Vector2(wall_dir * WALL_JUMP_FORCE.x, WALL_JUMP_FORCE.y)
			change_state(State.WALL_JUMP)

		elif jump_count < max_jumps:
			velocity.y = JUMP_VELOCITY
			jump_count += 1
			change_state(State.DOUBLE_JUMP)

	move_and_slide()

	update_state(direction)
	update_animation(direction)

	# Flip sprite
	if direction != 0:
		sprite.flip_h = direction < 0


func lose_life() -> void:
	if is_dead:
		return

	is_dead = true
	Engine.time_scale = 0.5
	change_state(State.HIT)

	var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
	if collision_shape:
		collision_shape.set_deferred("disabled", true)

	remaining_lives = max(remaining_lives - 1, 0)
	update_life_ui()

	if remaining_lives == 0:
		game_over_label.text = "Connection Failed"
		game_over_label.visible = true
		await get_tree().create_timer(1.2).timeout
		Engine.time_scale = 1.0
		remaining_lives = STARTING_LIVES
		get_tree().change_scene_to_file(MAIN_MENU_PATH)
		return

	await get_tree().create_timer(0.6).timeout
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()


func update_life_ui() -> void:
	hearts_label.text = "<3".repeat(remaining_lives)


func update_state(direction: float) -> void:
	if state == State.WALL_JUMP:
		if is_on_floor():
			change_state(State.IDLE)
		return

	if not is_on_floor():
		if velocity.y < 0:
			if jump_count == 2:
				change_state(State.DOUBLE_JUMP)
			else:
				change_state(State.JUMP)
		else:
			change_state(State.FALL)
	else:
		if direction != 0:
			change_state(State.RUN)
		else:
			change_state(State.IDLE)


func update_animation(direction: float) -> void:
	match state:
		State.IDLE:
			play_anim("idle")
		State.RUN:
			play_anim("running")
		State.JUMP:
			play_anim("jumping")
		State.FALL:
			play_anim("falling")
		State.DOUBLE_JUMP:
			play_anim("double_jumping")
		State.WALL_JUMP:
			play_anim("wall_jumping")
		State.HIT:
			play_anim("getting_hit")


func change_state(new_state: State) -> void:
	if state == new_state:
		return
	state = new_state


func play_anim(anim_name: String) -> void:
	if sprite.animation != anim_name:
		sprite.play(anim_name)
 
