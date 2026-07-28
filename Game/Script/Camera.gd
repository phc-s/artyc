extends Camera2D

@export var car_path: NodePath
var min_car_speed: float = 0.0
var max_car_speed: float = 450.0  

var fixed_zoom: Vector2 = Vector2(1.0, 1.0)
var min_zoom: Vector2 = Vector2(1.8, 1.8)     # Zoom when stationary
var max_zoom: Vector2 = Vector2(0.9, 0.9)     # Broader view when fast (smaller vector = wider view)
var zoom_smooth_speed: float = 5.0         

var zoom_step: float = 0.1
var min_manual_zoom: Vector2 = Vector2(0.2, 0.2)
var max_manual_zoom: Vector2 = Vector2(5.0, 5.0)

enum CameraMode { FIXED, SPEED_BASED }
var current_mode: CameraMode = CameraMode.SPEED_BASED

var car_node: Node2D

func _ready() -> void:
	make_current()
	
	if not car_path.is_empty():
		car_node = get_node_or_null(car_path) as Node2D
	
	if not car_node:
		car_node = get_tree().get_first_node_in_group("player") as Node2D
		if not car_node:
			var parent = get_parent()
			if parent is RigidBody2D:
				car_node = parent

	if car_node:
		print("Camera linked to car: ", car_node.name)
	else:
		push_warning("Camera2D: not found any car node!")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_camera_mode"):
		_toggle_camera_mode()
	 
	if current_mode == CameraMode.FIXED:
		if event.is_action_pressed("zoom_in"):
			fixed_zoom = clamp_vector2(fixed_zoom + Vector2(zoom_step, zoom_step), min_manual_zoom, max_manual_zoom)
		elif event.is_action_pressed("zoom_out"):
			fixed_zoom = clamp_vector2(fixed_zoom - Vector2(zoom_step, zoom_step), min_manual_zoom, max_manual_zoom)

func _physics_process(delta: float) -> void:
	var target_zoom: Vector2 = fixed_zoom
	 
	match current_mode:
		CameraMode.FIXED:
			target_zoom = fixed_zoom
			 
		CameraMode.SPEED_BASED:
			var current_speed = abs(_get_car_speed())
			var speed_factor = inverse_lerp(min_car_speed, max_car_speed, current_speed)
			speed_factor = clamp(speed_factor, 0.0, 1.0)
			target_zoom = min_zoom.lerp(max_zoom, speed_factor)

	zoom = zoom.lerp(target_zoom, zoom_smooth_speed * delta)

func _toggle_camera_mode() -> void:
	if current_mode == CameraMode.FIXED:
		current_mode = CameraMode.SPEED_BASED
		print("Camera Mode: Speed-Based Zoom")
	else:
		current_mode = CameraMode.FIXED
		print("Camera Mode: Fixed (Manual Scroll Enabled)")

func _get_car_speed() -> float:
	if not car_node:
		return 0.0
	 
	if "current_velocity" in car_node:
		return car_node.current_velocity
	elif car_node is RigidBody2D:
		return (car_node as RigidBody2D).linear_velocity.length()
	elif "speed" in car_node:
		return car_node.speed
	elif car_node.has_method("get_speed"):
		return car_node.call("get_speed")
		 
	return 0.0

func clamp_vector2(val: Vector2, min_v: Vector2, max_v: Vector2) -> Vector2:
	return Vector2(
		clamp(val.x, min_v.x, max_v.x),
		clamp(val.y, min_v.y, max_v.y)
	)
