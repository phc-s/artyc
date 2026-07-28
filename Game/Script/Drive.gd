extends RigidBody2D

const ACCEL: float = 1.0
const MAX_SPEED: float = 450.0

var steering_input: float = 0.0
const STEER_SENSE: float = 0.005
const STEER_RETURN: float = 0.01
const GRIP: float = 0.05

var current_velocity: float = 0.0
var drift_velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:

	if current_velocity > MAX_SPEED:
		current_velocity = MAX_SPEED
		
	if Input.is_action_pressed("up"):
		current_velocity += ACCEL
	if Input.is_action_pressed("down"):
		current_velocity -= ACCEL * 4
	else:
		if current_velocity <= 0:
			current_velocity = 0
		else:
			current_velocity -= 0.5

	var speed_factor: float = abs(current_velocity) / MAX_SPEED
	var current_steer_sense: float = STEER_SENSE * (1.0 + (speed_factor * -0.4))

	if Input.is_action_pressed("left"):
		steering_input -= current_steer_sense
	elif Input.is_action_pressed("right"):
		steering_input += current_steer_sense
	else:
		if abs(steering_input) < STEER_RETURN:
			steering_input = 0.0
		else:
			steering_input -= sign(steering_input) * STEER_RETURN
			
	steering_input = clamp(steering_input, -1.0, 1.0)

	rotation += steering_input * (abs(current_velocity) * 0.00033)

	var target_velocity: Vector2 = Vector2.from_angle(rotation) * current_velocity
	drift_velocity = drift_velocity.lerp(target_velocity, GRIP)

	linear_velocity = drift_velocity
