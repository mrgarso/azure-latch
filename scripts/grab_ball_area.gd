extends Area3D

signal ball_headed

@onready var actual_force := curvature_force * strength
@export var kick_modes :Array[float] = [0.1, 0.5]
@export var strength := 1.0
@export var shot_speed := 1.0
@export var kick_strengths :Array[float] = [10.0, 25.0, 75.0]
@export var ball_holder: Node3D
@export var ball_header_holder: Node3D
@export var player: Player
@export var camera_3d: Camera3D
@export var sidespin_amount := 2.5
@export var topspin_amount := 0.0
@export var time_for_curve := 3.0
@export var curvature_force := 0.2
@export var curve_pitch_power := 0.025

var ball : Ball = null:
	set(value):
		ball = value
		hold_time = 0.0
		if value != null:
			value.global_position = ball_holder.global_position
			if volleying:
				volleying = false
				while player.ball == null: await get_tree().physics_frame
				SB.screen_flash(player, Color(0.8,0.8,0.8,0.5), 0.5)
				while player.ball != null: SB.kick(player, Vector3(0, -0.12, 1), 70, true, 1.7)
var can_grab := true
var volleying := false
var hold_time := 0.0
var kick_strength := 5.0
var ball_curve_friction := 1.0

func _physics_process(delta: float) -> void:
	if player.mode != "player": return
	if hold_time < kick_modes[0]:
		kick_strength = kick_strengths[0] * strength
	elif hold_time < kick_modes[1]:
		kick_strength = kick_strengths[1] * strength
	else:
		kick_strength = kick_strengths[2] * strength
	if ball and !player.using_move:
		ball_holder.global_position = player.model.ball_holder.global_position
		ball.global_position = ball_holder.global_position
		ball_curve_friction = ball.curve_friction
		var pitch_up := clampf(player.spring_arm_3d.rotation.x, 0.0, PI / 2.0)
		player.model.set_modulate(Color(1,1,1, -pitch_up * 8.0 + 2), true)
		var pitch_scale := pow(cos(pitch_up), curve_pitch_power)
		
		var lateral_speed := ( -player.velocity.dot(player.sides) * player.speed_on_ball)
		var curvature_dir: Vector3 = player.up * (sidespin_amount * -(lateral_speed * 2.0)) + player.sides * topspin_amount
		var effective_curve_force := curvature_force * strength * pitch_scale
		
		var friction := ball.curve_friction if ball else 0.0
		var lateral_dir_offset := (lateral_speed / 50.0) * friction * sidespin_amount * time_for_curve * effective_curve_force
		
		
		#the purpose in all of this, is to make the player be able to curve the ball on the direction
		#they're moving on, plus a vertical diffusor for the curve, meaning that the more
		#up u point, the less curve youll have
		
		if Input.is_action_pressed("m1"):
			player.shooting = true
			if hold_time < 1:
				hold_time += delta
			if ball:
				SB.kick(player, Vector3(0 + lateral_dir_offset, min(-pitch_up * 1.2, 0), 1), \
				kick_strength, false, shot_speed, true, curvature_dir, \
				time_for_curve, curvature_force)
		
		elif Input.is_action_just_released("m1") and hold_time:
			player.model.set_modulate(Color(1,1,1,1), false)
			player.shooting = false
			if ball:
				SB.kick(player, Vector3(0 + lateral_dir_offset, min(-pitch_up * 1.2, 0), 1), \
				kick_strength, true, shot_speed, true, curvature_dir, \
				time_for_curve, curvature_force)
			hold_time = 0


func _input(_event: InputEvent) -> void:
	if player.mode != "player": return
	if !ball and !player.using_move:
		if Input.is_action_pressed("m1") and Input.is_action_pressed("m2") and !volleying:
			volleying = true
			SB.fov_change(player, 70, 60, 0.35, SB.Interp.EXPO_IN)
			await SB.wait(20, 1.0)
			await SB.hitbox(player, Vector3.ONE * 15, Vector3.ZERO, 0.05, \
			SB.HitboxTargets.BALL)
			SB.fov_change(player, 90, 70, 0.5)
			await SB.wait(30, 1.0)
			volleying = false

func _on_area_entered(area: Node3D) -> void:
	var target :Node3D= area.get_parent()
	if target is Ball and can_grab and ball == null and target.current_owner == null:
		target = target as Ball
		player.ball = target
		target.current_owner = player
		if !player.is_on_floor() and !player.using_move: 
			target.global_position = ball_header_holder.global_position
			player.moves.headed_ball = true
			SB.kick(player, Vector3(0,-0.5,1), 30.0, true, shot_speed * 2, \
			false, Vector3(), 0.0, 0.0)
			ball_headed.emit()


func _on_area_exited(area: Node3D) -> void:
	var _target :Node3D= area.get_parent()
	#if target is Ball:
		#print("ballin n't ", target)
		#target.current_owner = null
		#target.last_owner = player
