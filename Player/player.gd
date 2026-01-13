extends RigidBody3D
class_name Player

@export_range(1000,2000) var thrust := 1000.0
@export_range(100.0,300) var torque_thrust := 100.0

@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio

var transitioning := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !transitioning:
		if Input.is_action_pressed("boost"):
			apply_central_force(basis.y * delta * thrust)
			if !rocket_audio.is_playing():
				rocket_audio.play()
		else:
			rocket_audio.stop()
		if Input.is_action_pressed("rotate left"):
			apply_torque(Vector3(0,0,1)* delta * torque_thrust)
		if Input.is_action_pressed("rotate right"):
			apply_torque(Vector3(0,0,1)* -delta * torque_thrust)
	if Input.is_action_pressed("reset"):
		get_tree().reload_current_scene.call_deferred()

func _on_body_entered(body: Node) -> void:
	if !transitioning:
		if "goal" in body.get_groups():
			print("you win")
			if body.file_path:
				complete_levle(body.file_path)
			else:
				print("No next level found")
		if "obsticals" in body.get_groups():
			crash_sequence()
	


func crash_sequence()->void:
	transitioning = true
	explosion_audio.play()
	print("KABOOM!")
	await get_tree().create_timer(2.5).timeout
	get_tree().reload_current_scene.call_deferred()

func complete_levle(next_level_file)->void:
	transitioning = true
	success_audio.play()
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file.call_deferred(next_level_file)
