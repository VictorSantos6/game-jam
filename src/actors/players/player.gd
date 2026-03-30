extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hearts_label: Label = $CanvasLayer/HUD/HeartsLabel
@onready var game_over_label: Label = $CanvasLayer/HUD/GameOverLabel

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const STARTING_LIVES := 3
const MAIN_MENU_PATH := "res://scenes/main_menu.tscn"
const PAUSE_MENU_PATH := "res://scenes/pause_menu.tscn"
const HIT_STUN_TIME := 0.4
const DEATH_FALL_TIME := 1.2
const FALL_LIMIT_MARGIN := 900.0
const DAMAGE_COOLDOWN_MS := 700

const WALL_JUMP_FORCE = Vector2(600,  -400)  # Increased horizontal push
const WALL_SLIDE_SPEED = 60.0  # Max speed when sliding down wall

static var remaining_lives := STARTING_LIVES

var jump_count := 0
var max_jumps := 2
var is_dead := false
var wall_jump_started := false
var is_in_hit_stun := false
var spawn_position := Vector2.ZERO
var fall_limit_y := 0.0
var last_damage_time_ms := -1000000

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
	spawn_position = global_position
	fall_limit_y = spawn_position.y + FALL_LIMIT_MARGIN
	update_life_ui()
	game_over_label.visible = false

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity += get_gravity() * delta
		move_and_slide()
		change_state(State.FALL)
		update_animation(0.0)
		return

	if global_position.y > fall_limit_y:
		lose_life(true)
		return

	if is_in_hit_stun:
		if not is_on_floor():
			velocity += get_gravity() * delta
		move_and_slide()
		update_animation(0.0)
		return

	# Gravity
	if not is_on_floor():
		if is_on_wall():
			# Wall slide: friction effect - slow descent
			velocity.y = move_toward(velocity.y, WALL_SLIDE_SPEED, get_gravity().y * delta)
		else:
			velocity += get_gravity() * delta

	# Reset jumps on floor
	if is_on_floor():
		jump_count = 0
		wall_jump_started = false

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
			wall_jump_started = true
			jump_count = max_jumps  # Consume air jumps so can't double-jump after wall jump
			change_state(State.WALL_JUMP)

		elif jump_count < max_jumps:
			velocity.y = JUMP_VELOCITY
			jump_count += 1
			wall_jump_started = false
			change_state(State.DOUBLE_JUMP)

	move_and_slide()

	update_state(direction)
	update_animation(direction)

	# Flip sprite
	if direction != 0:
		sprite.flip_h = direction < 0


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_P:
			_show_pause_menu()


func _show_pause_menu() -> void:
	if is_dead:
		return
	get_tree().paused = true
	var pause_menu = load(PAUSE_MENU_PATH).instantiate()
	add_child(pause_menu)


func lose_life(respawn_at_spawn: bool = false) -> void:
	if is_dead or is_in_hit_stun:
		return

	var now_ms := Time.get_ticks_msec()
	if now_ms - last_damage_time_ms < DAMAGE_COOLDOWN_MS:
		return
	last_damage_time_ms = now_ms

	var should_respawn := respawn_at_spawn or global_position.y > fall_limit_y

	is_in_hit_stun = true
	change_state(State.HIT)
	velocity = Vector2(-120.0 if sprite.flip_h else 120.0, -180.0)

	remaining_lives = max(remaining_lives - 1, 0)
	update_life_ui()

	if remaining_lives == 0:
		is_dead = true
		is_in_hit_stun = false
		var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
		if collision_shape:
			collision_shape.set_deferred("disabled", true)
		velocity = Vector2(0.0, -120.0)
		game_over_label.text = "Connection Failed"
		game_over_label.visible = true
		await get_tree().create_timer(DEATH_FALL_TIME).timeout
		remaining_lives = STARTING_LIVES
		get_tree().change_scene_to_file(MAIN_MENU_PATH)
		return

	if should_respawn:
		global_position = spawn_position
		velocity = Vector2.ZERO
		jump_count = 0
		wall_jump_started = false
		await get_tree().create_timer(HIT_STUN_TIME).timeout
		is_in_hit_stun = false
		change_state(State.IDLE)
		return

	await get_tree().create_timer(HIT_STUN_TIME).timeout
	is_in_hit_stun = false
	change_state(State.IDLE)


func update_life_ui() -> void:
	hearts_label.text = "<3".repeat(remaining_lives)


func update_state(direction: float) -> void:
	if state == State.HIT:
		return

	if state == State.WALL_JUMP:
		if is_on_floor():
			change_state(State.IDLE)
		elif is_on_wall() and velocity.y < 0:
			change_state(State.JUMP)
		elif not is_on_wall():
			if velocity.y < 0:
				change_state(State.JUMP)
			else:
				change_state(State.FALL)
		return

	if not is_on_floor():
		if is_on_wall() and velocity.y >= 0:
			wall_jump_started = false
			change_state(State.WALL_JUMP)
		elif velocity.y < 0:
			if wall_jump_started:
				change_state(State.JUMP)
			elif jump_count == 2:
				change_state(State.DOUBLE_JUMP)
			else:
				change_state(State.JUMP)
		else:
			wall_jump_started = false
			change_state(State.FALL)
	else:
		if direction != 0:
			change_state(State.RUN)
		else:
			change_state(State.IDLE)


func update_animation(_direction: float) -> void:
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
 
