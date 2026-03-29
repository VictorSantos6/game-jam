extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0

const WALL_JUMP_FORCE = Vector2(300, -400)
const WALL_JUMP_LOCK_TIME = 0.15
const WALL_JUMP_COOLDOWN_TIME = 0.20

var jump_count := 0
var max_jumps := 2

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
var wall_jump_lock_timer := 0.0
var wall_jump_cooldown_timer := 0.0
var wall_jump_flip_h := false

func _physics_process(delta: float) -> void:
	if wall_jump_lock_timer > 0.0:
		wall_jump_lock_timer = max(0.0, wall_jump_lock_timer - delta)

	if wall_jump_cooldown_timer > 0.0:
		wall_jump_cooldown_timer = max(0.0, wall_jump_cooldown_timer - delta)

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Reset jumps on floor
	if is_on_floor():
		jump_count = 0

	var direction = Input.get_axis("left", "right")

	# Horizontal movement
	if wall_jump_lock_timer <= 0.0:
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

		elif is_on_wall() and wall_jump_cooldown_timer <= 0.0:
			var wall_dir = get_wall_normal().x
			velocity = Vector2(wall_dir * WALL_JUMP_FORCE.x, WALL_JUMP_FORCE.y)
			wall_jump_lock_timer = WALL_JUMP_LOCK_TIME
			wall_jump_cooldown_timer = WALL_JUMP_COOLDOWN_TIME
			jump_count = max_jumps
			# Face away from the wall while wall-jumping.
			wall_jump_flip_h = wall_dir < 0.0
			sprite.flip_h = wall_jump_flip_h
			change_state(State.WALL_JUMP)

		elif jump_count < max_jumps:
			velocity.y = JUMP_VELOCITY
			jump_count += 1
			change_state(State.DOUBLE_JUMP)

	move_and_slide()

	update_state(direction)
	update_animation(direction)

	# Keep wall-jump facing locked immediately after jumping from a wall.
	if wall_jump_lock_timer > 0.0:
		sprite.flip_h = wall_jump_flip_h
	# Flip sprite from input when not in wall-jump lock.
	elif direction != 0:
		sprite.flip_h = direction < 0


func update_state(direction: float) -> void:
	if is_on_floor():
		if direction != 0:
			change_state(State.RUN)
		else:
			change_state(State.IDLE)
		return

	if wall_jump_lock_timer > 0.0:
		change_state(State.WALL_JUMP)
		return

	if velocity.y < 0:
		if jump_count == 2:
			change_state(State.DOUBLE_JUMP)
		else:
			change_state(State.JUMP)
	else:
		change_state(State.FALL)


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
