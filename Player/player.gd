extends RigidBody3D
class_name Player

@export_range(1000,2000) var thrust := 1000.0
@export_range(100.0,300) var torque_thrust := 100.0
@export var starting_fuel := 100



@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var MainBooster: GPUParticles3D = $MainBooster
@onready var right_booster: GPUParticles3D = $RightBooster
@onready var left_booster: GPUParticles3D = $LeftBooster
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles

var ui : CanvasLayer
var fuel : float:
	set(new_fuel):
		fuel = new_fuel
		ui.update_fuel(new_fuel)
		
var transitioning := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ui = get_tree().get_first_node_in_group("UI")
	fuel = starting_fuel


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !transitioning:
		if Input.is_action_pressed("boost") and fuel > 0:
			apply_central_force(basis.y * delta * thrust)
			fuel -= 0.3
			MainBooster.emitting=true
			if !rocket_audio.is_playing():
				rocket_audio.play()
		else:
			rocket_audio.stop()
			MainBooster.emitting = false
		if Input.is_action_pressed("rotate left"):
			apply_torque(Vector3(0,0,1)* delta * torque_thrust)
			right_booster.emitting=true
		else:
			right_booster.emitting = false
		if Input.is_action_pressed("rotate right"):
			apply_torque(Vector3(0,0,1)* -delta * torque_thrust)
			left_booster.emitting = true
		else:
			left_booster.emitting = false
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
	MainBooster.emitting = false
	right_booster.emitting = false
	left_booster.emitting = false
	rocket_audio.stop()
	explosion_particles.emitting = true
	print("KABOOM!")
	await get_tree().create_timer(2.5).timeout
	get_tree().reload_current_scene.call_deferred()

func complete_levle(next_level_file)->void:
	transitioning = true
	success_audio.play()
	rocket_audio.stop()
	success_particles.emitting = true
	MainBooster.emitting = false
	right_booster.emitting = false
	left_booster.emitting = false
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file.call_deferred(next_level_file)
