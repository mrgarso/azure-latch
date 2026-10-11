extends Node

@onready var player :Player= $".."

func _unhandled_key_input(event: InputEvent) -> void:
	if !player.using_move and player.mode == "player":
		if Input.is_action_just_pressed("e"):
			var dir := Input.get_axis("a","d")
			if dir == 0:
				player.using_move = true
				var tackle_duration := 1.5
				SB.velocity(get_parent(), true, Vector3(0,1,-6), tackle_duration, 0.923)
				var enemy_tackled := SB.hitbox_detailed_list
				for i in int(Engine.physics_ticks_per_second * tackle_duration):
					#if player.ball != null: 
						#if enemy_tackled["collided"].ball != null:
							#break
					enemy_tackled = await SB.hitbox_detailed(player, Vector3.ONE * 5, Vector3.ZERO, (Engine.time_scale / Engine.physics_ticks_per_second) * 1, SB.HitboxTargets.PLAYERS)
					
					#print(enemy_tackled)
				
				SB.clear_velocities(player)
				player.using_move = false
				return
			SB.velocity(get_parent(), true, Vector3(dir * 5,0,0), 0.1, 0.8, 40.0, true)
