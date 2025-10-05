extends ColorRect

@export var next_scene_path := "res://main.tscn"

var can_click := false

func _ready():
	$AnimationPlayer.play("splash_sequence")
	await get_tree().create_timer(6.2).timeout
	can_click = true

func _input(event):
	if can_click and event is InputEventMouseButton and event.pressed:
		can_click = false
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.8)
		await tween.finished
		get_tree().change_scene_to_file(next_scene_path)
