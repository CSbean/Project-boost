extends RigidBody3D
class_name Player

@export_range(1000,2000) var thrust := 1000.0
@export_range(100.0,300) var torque_thrust := 100.0

var playing := true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if playing:
		if Input.is_action_pressed("boost"):
			apply_central_force(basis.y * delta * thrust)
		if Input.is_action_pressed("rotate left"):
			apply_torque(Vector3(0,0,1)* delta * torque_thrust)
		if Input.is_action_pressed("rotate right"):
			apply_torque(Vector3(0,0,1)* -delta * torque_thrust)
	if Input.is_action_pressed("reset"):
		get_tree().reload_current_scene.call_deferred()

func _on_body_entered(body: Node) -> void:
	if "goal" in body.get_groups():
		print("you win")
		if body.file_path:
			complete_levle(body.file_path)
		else:
			print("No next level found")
	if "obsticals" in body.get_groups():
		crash_sequence()
	


func crash_sequence()->void:
	print("KABOOM!")
	playing = false
	await get_tree().create_timer(2.5).timeout
	get_tree().reload_current_scene.call_deferred()

func complete_levle(next_level_file)->void:
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file.call_deferred(next_level_file)
