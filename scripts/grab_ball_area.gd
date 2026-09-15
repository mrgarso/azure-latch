extends Area3D

var ball : Ball = null
var holding := false
var hold_time := 0.0
var kick_strength := 5.0
@export var kick_modes :Array[float] = [0.1, 0.5]
@export var kick_strengths :Array[float] = [10.0, 30.0, 75.0]
@export var ball_holder: Node3D
@export var player: Player
@export var ball_aim: MeshInstance3D

func _physics_process(delta: float) -> void:
	match hold_time:
		var x when x < kick_modes[0]:
			kick_strength = kick_strengths[0]
		var x when x >= kick_modes[0] and x < kick_modes[1]:
			kick_strength = kick_strengths[1]
		var x when x >= kick_modes[1]:
			kick_strength = kick_strengths[2]
	if ball:
		ball.global_position = ball_holder.global_position
	if Input.is_action_pressed("m1"):
		if hold_time < 1:
			hold_time += delta
		if ball:
			SB.kick(player, Vector3(0, max(player.spring_arm_3d.rotation.x * 4, 0), 1), kick_strength, false, 1.3)
			
	elif Input.is_action_just_released("m1") and hold_time:
		if ball:
			SB.kick(player, Vector3(0, max(player.spring_arm_3d.rotation.x * 4, 0), 1), kick_strength, true, 1.3)
		hold_time = 0


func _input(event: InputEvent) -> void:
	if !ball:
		if Input.is_action_pressed("m1") and Input.is_action_pressed("m2"):
			SB.fov_change(player, 70, 50, 0.45)
			await SB.wait(30, 1.0)
			SB.fov_change(player, 90, 70, 0.5)

func _on_area_entered(area: Node3D) -> void:
	var target :Node3D= area.get_parent()
	if target is Ball:
		ball = target
		target.current_owner = player


func _on_area_exited(area: Node3D) -> void:
	var _target :Node3D= area.get_parent()
	#if target is Ball:
		#print("ballin n't ", target)
		#target.current_owner = null
		#target.last_owner = player
