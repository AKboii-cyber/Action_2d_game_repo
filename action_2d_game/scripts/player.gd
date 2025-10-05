extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# --------- MOVEMENT ----------
const SPEED: float = 160.0
const JUMP_VELOCITY: float = -320.0

# --------- DOUBLE JUMP -------
const EXTRA_JUMPS: int = 1
var air_jumps_left: int = EXTRA_JUMPS

# --------- DASH (ROLL) -------
const DASH_SPEED: float = 600.0
const DASH_TIME: float = 0.18
const DASH_COOLDOWN: float = 0.5
const DASH_CANCELS_VERTICAL: bool = true
const DASH_KEEP_MOMENTUM: bool = true

var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_dir: int = 0  # -1 left, 1 right

func _physics_process(delta: float) -> void:
	# Timers first
	update_dash_timers(delta)

	# Dash input
	if Input.is_action_just_pressed("speed_dash"):
		try_start_dash()

	# Gravity
	if not is_on_floor() and not is_dashing:
		velocity += get_gravity() * delta

	# Jump input
	handle_jump_input()

	# Horizontal movement (disabled while dashing)
	if is_dashing:
		perform_dash_motion()
	else:
		handle_horizontal_movement(delta)

	move_and_slide()
	post_move_updates()
	update_animations()

# ---------- JUMP -------------
func handle_jump_input() -> void:
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			perform_jump(true)
		elif air_jumps_left > 0:
			perform_jump(false)
			air_jumps_left -= 1

func perform_jump(reset_air_jumps: bool) -> void:
	velocity.y = JUMP_VELOCITY
	if reset_air_jumps:
		air_jumps_left = EXTRA_JUMPS

# ----- HORIZONTAL MOVE -------
func handle_horizontal_movement(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")

	# Flip sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Apply velocity
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

# ----------- DASH ------------
func try_start_dash() -> void:
	if is_dashing or dash_cooldown_timer > 0.0:
		return

	var input_dir := Input.get_axis("move_left", "move_right")
	if input_dir == 0:
		# If no input, dash toward facing
		dash_dir = -1 if animated_sprite.flip_h else 1
	else:
		dash_dir = sign(input_dir)

	is_dashing = true
	dash_timer = DASH_TIME
	dash_cooldown_timer = DASH_COOLDOWN

	# Lock facing to dash direction
	animated_sprite.flip_h = dash_dir < 0

	if DASH_CANCELS_VERTICAL:
		velocity.y = 0.0
	velocity.x = dash_dir * DASH_SPEED

	# Play roll animation during dash
	animated_sprite.play("roll")

func perform_dash_motion() -> void:
	velocity.x = dash_dir * DASH_SPEED

func end_dash() -> void:
	is_dashing = false
	if not DASH_KEEP_MOMENTUM:
		velocity.x = 0.0

func update_dash_timers(delta: float) -> void:
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			end_dash()

# ------- POST-MOVE ----------
func post_move_updates() -> void:
	# Reset air jumps when grounded and not dashing
	if is_on_floor() and not is_dashing:
		air_jumps_left = EXTRA_JUMPS

func update_animations() -> void:
	if is_dashing:
		# Keep roll playing during dash
		if animated_sprite.animation != "roll":
			animated_sprite.play("roll")
		return

	if is_on_floor():
		var direction := Input.get_axis("move_left", "move_right")
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
