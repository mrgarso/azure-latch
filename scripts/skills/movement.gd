extends Node
class_name Movement

@onready var player :Player= $".."
@onready var field : Field = get_tree().current_scene
var headed_ball := false

func _unhandled_key_input(event: InputEvent) -> void:
	
	if !player.using_move and player.mode == "player":
		if Input.is_action_just_pressed("q"):
			dribble()
		if Input.is_action_just_pressed("e"):
			tackle_and_dash(false, false)

func gk_tackles(dir := 0.0, custom_velocity := false, velocity := 0.0) -> void:
	player.using_move = true
	player.velocity = Vector3.ZERO
	var tackle_velocity := 27.5 if !custom_velocity else velocity
	var tackle_time := 1.25
	var tackle_radius := 7.0
	var front := float(dir == 0.0)
	var final_dir := Vector3(dir,0,-front) * tackle_velocity
	SB.velocity(player, true, final_dir, tackle_time, \
	0.6, 10.0, false, true)
	for i in int(tackle_time * 10) / 3:
		
		await SB.hitbox(player, Vector3.ONE * tackle_radius, final_dir / tackle_velocity, \
		0.1, SB.HitboxTargets.BALL if (field.match_ball != null and \
		field.match_ball.current_owner == null) else SB.HitboxTargets.PLAYERS)
	for i in int(tackle_time * 10) & 3:
		
		await SB.hitbox(player, Vector3.ONE * tackle_radius / 3, Vector3.ZERO, \
		0.1, SB.HitboxTargets.BALL if (field.match_ball != null and \
		field.match_ball.current_owner == null) else SB.HitboxTargets.PLAYERS)
	player.current_gravity = player.gravity
	player.using_move = false

func tackle_and_dash(reset_position := false, tackle := true, pre_dir := "none") -> void:
	var init_pos := player.global_position
	var dir := Input.get_axis("a","d")
	if player.role == "gk":
		await gk_tackles(dir)
		return
	if headed_ball: headed_ball = false
	if tackle: dir = 0
	else:
		match pre_dir:
			"right":
				dir = 1
			"left":
				dir = -1
			_:
				pass
	if dir == 0 and player.ball == null:
		player.using_move = true
		var tackle_duration := 0.9
		player.velocity.y = 20.0
		SB.velocity(get_parent(), true, Vector3(0,0,-6), tackle_duration, 0.923)
		var enemy_tackled := SB.hitbox_detailed_list
		for i in int(Engine.physics_ticks_per_second * tackle_duration):
			var enemy = enemy_tackled["collided"]
			if player.ball == null and enemy != null: 
				if enemy.ball != null:
					#TACKLEADA PASA AQUI <--------------------------------
					var target = enemy as Player
					if target.dribbling:
						SB.clear_velocities(player)
						SB.velocity(player, true, \
						player.global_position.direction_to(target.global_position) * 0.5, \
						0.5, 0.8, 40.0, true, true)
					else:
						SB.fov_change(player, 80, 70, 0.6, SB.Interp.EXPO_IN)
						SB.velocity(player, true, Vector3(0,0,-1), 0.4, 0.9, 40.0, true)
						target.tackled(player, 2)
			enemy_tackled = await SB.hitbox_detailed(player, Vector3(2.5, 5.0, 2.5), Vector3(0, -2.5, 0), \
			(Engine.time_scale / Engine.physics_ticks_per_second) * 1, SB.HitboxTargets.PLAYERS, \
			true, false, false, true)
			if player.ball != null or headed_ball:
				headed_ball = false
				break
			#print(enemy_tackled)
		if reset_position: player.global_position = init_pos
		SB.clear_velocities(player)
		player.using_move = false
		return
	SB.velocity(get_parent(), true, Vector3(dir * 5,0,0), 0.1, 0.8, 40.0, true)

func dribble(dribble_time := 1.0) -> void:
	player.dribbling = true
	var dir := Vector3(Input.get_axis("a","d"), 0 , Input.get_axis("w", "s"))
	print(dir)
	var dash_duration := 0.1
	await SB.velocity(player, true, dir * 30, dash_duration, 0.4, 40.0, true)
	if (dribble_time - dash_duration >= 0): 
		await SB.wait(int((dribble_time - dash_duration) * 60))
	player.dribbling = false

func jump() -> void:
	pass
