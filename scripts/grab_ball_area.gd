extends Area3D

var ball : Ball = null
var holding := false
var hold_time := 0.0
@export var kick_strength := 5.0
@export var ball_holder: Node3D
@export var player: Player
@export var ball_aim: MeshInstance3D

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("m1"):
		hold_time += delta
	elif Input.is_action_just_released("m1") and hold_time:
		if ball:
			SB.kick(player, Vector3(0, min(-player.spring_arm_3d.rotation.x, 0), 1), 100.0)
			ball.current_owner = null
			ball.last_owner = player
			ball = null
		hold_time = 0
	if ball:
		ball.global_position = ball_holder.global_position
	#if ball:
		#ball.global_position = (ball_holder.global_position)
		#if Input.is_action_just_pressed("m1"):
			#ball.global_rotation = Vector3.ZERO
			#ball.apply_impulse(((-player.transform.basis.z * 10) + (Vector3(0,max(player.spring_arm_3d.rotation.x, 0), 0) * 10)) * kick_strength)
			#
			#SB.kick(player, Vector3(0, min(-player.spring_arm_3d.rotation.x, 0), 1), 100.0)
			#ball.current_owner = null
			#ball.last_owner = player
			#ball = null

func _on_area_entered(area: Node3D) -> void:
	var target :Node3D= area.get_parent()
	if target is Ball:
		ball = target
		target.current_owner = player


func _on_area_exited(area: Node3D) -> void:
	var target :Node3D= area.get_parent()
	#if target is Ball:
		#print("ballin n't ", target)
		#target.current_owner = null
		#target.last_owner = player
