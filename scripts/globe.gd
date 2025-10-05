# globe_controller.gd
extends Node3D

@export var globe_radius := 0.95
@onready var marker := $marker                     # StaticBody3D
@onready var camera := $"../Camera3D"             # adjust path if different

const LAT := 34.7
const LON := -118.4

func _ready():
	# position marker just above globe surface
	marker.position = latlon_to_xyz(LAT, LON, globe_radius + 0.06)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var from = camera.project_ray_origin(event.position)
		var to   = from + camera.project_ray_normal(event.position) * 1000.0

		var space_state = get_world_3d().direct_space_state

		# Create PhysicsRayQueryParameters3D
		var params = PhysicsRayQueryParameters3D.new()
		params.from = from
		params.to   = to
		# optional: exclude the camera itself or other nodes
		# params.exclude = [camera]

		var result : Dictionary = space_state.intersect_ray(params)
		if result.size() > 0:
			var collider = result.get("collider")     # the node hit
			if collider == marker:
				_on_marker_clicked()
			else:
				# debug: print the hit object
				print("Hit:", collider, "name:", collider.name)
		# else nothing hit

func _on_marker_clicked():
	print("Marker clicked! show region data")
	# call your camera fly-in / ui toggles here

func latlon_to_xyz(lat: float, lon: float, radius: float) -> Vector3:
	var lat_r = deg_to_rad(lat)
	var lon_r = deg_to_rad(lon)
	var x = radius * cos(lat_r) * cos(lon_r)
	var y = radius * sin(lat_r)
	var z = radius * cos(lat_r) * sin(lon_r)
	return Vector3(x, y, z)
