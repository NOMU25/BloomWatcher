extends Camera3D

@export var rotate_speed := 0.01
@export var zoom_speed := 2.0
@export var idle_rotate_speed := 0.005
@export var idle_delay := 2.0
@export var idle_accel_time := 3.0
@export var smooth_factor := 8.0

var distance := 1.0
var target_distance := 2.0
var rotation_x := 0.0
var rotation_y := 0.0
var target_rotation_x := 0.0
var target_rotation_y := 0.0

var last_input_time := 0.0
var idle_time := 0.0
var idle_speed_factor := 0.0

func _ready():
	last_input_time = Time.get_ticks_msec() / 1000.0

func _input(event):
	var current_time = Time.get_ticks_msec() / 1000.0

	# Handle mouse drag
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		target_rotation_y -= event.relative.x * rotate_speed
		target_rotation_x -= (-event.relative.y) * rotate_speed
		target_rotation_x = clamp(target_rotation_x, -PI / 4, PI / 4)
		last_input_time = current_time

	# Handle zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			target_distance -= zoom_speed * 0.1
			last_input_time = current_time
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			target_distance += zoom_speed * 0.1
			last_input_time = current_time

	target_distance = clamp(target_distance, 2.0, 20.0)

func _process(delta):
	var current_time = Time.get_ticks_msec() / 1000.0
	idle_time = current_time - last_input_time

	# Smooth transitions for drag and zoom
	rotation_x = lerp(rotation_x, target_rotation_x, delta * smooth_factor)
	rotation_y = lerp_angle(rotation_y, target_rotation_y, delta * smooth_factor)
	distance = lerp(distance, target_distance, delta * smooth_factor)

	# Idle rotation logic
	if idle_time > idle_delay:
		idle_speed_factor += delta / idle_accel_time
		idle_speed_factor = clamp(idle_speed_factor, 0.0, 1.0)
		target_rotation_y += idle_rotate_speed * idle_speed_factor * delta * 60.0
	else:
		idle_speed_factor = 0.0

	# Update camera position
	var target = Vector3(0, 0, 0)
	var pos = Vector3(
		distance * cos(rotation_x) * sin(rotation_y),
		distance * sin(rotation_x),
		distance * cos(rotation_x) * cos(rotation_y)
	)
	global_position = target + pos
	look_at(target)
