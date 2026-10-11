extends Node

@onready var player :Player= $".."

func _unhandled_key_input(event: InputEvent) -> void:
	if !player.using_move and player.mode == "player":
		if Input.is_action_just_pressed("e"):
			tackle_and_dash()

func tackle_and_dash(reset_position := false) -> void:
	var init_pos := player.global_position
	var dir := Input.get_axis("a","d")
	if dir == 0:
		player.using_move = true
		var tackle_duration := 0.9
		SB.velocity(get_parent(), true, Vector3(0,1,-6), tackle_duration, 0.923)
		var enemy_tackled := SB.hitbox_detailed_list
		for i in int(Engine.physics_ticks_per_second * tackle_duration):
			if player.ball == null and enemy_tackled["collided"] != null: 
				if enemy_tackled["collided"].ball != null:
					#TACKLEADA PASA AQUI <--------------------------------
					SB.fov_change(player, 80, 70, 0.6, SB.Interp.EXPO_IN)
					var target = enemy_tackled["collided"] as Player
					SB.velocity(player, true, Vector3(0,0,-1), 0.4, 0.9, 40.0, true)
					target.tackled(player, 2)
			enemy_tackled = await SB.hitbox_detailed(player, Vector3.ONE * 5, Vector3.ZERO, \
			(Engine.time_scale / Engine.physics_ticks_per_second) * 1, SB.HitboxTargets.PLAYERS, \
			true, false, false, true)
			if player.ball != null: break
			#print(enemy_tackled)
		if reset_position: player.global_position = init_pos
		SB.clear_velocities(player)
		player.using_move = false
		return
	SB.velocity(get_parent(), true, Vector3(dir * 5,0,0), 0.1, 0.8, 40.0, true)
