extends Node

@onready var player :Player= $".."

func _unhandled_key_input(event: InputEvent) -> void:
	if !player.using_move and player.mode == "player":
		if Input.is_action_just_pressed("e"):
			var dir := Input.get_axis("a","d")
			if dir == 0:
				player.using_move = true
				var tackle_duration := 0.9
				SB.hitbox(player, Vector3.ONE * 5, Vector3.ZERO, tackle_duration, SB.HitboxTargets.PLAYERS)
				await SB.velocity(get_parent(), true, Vector3(0,1,-5), tackle_duration, 0.95)
				player.using_move = false
				return
			SB.velocity(get_parent(), true, Vector3(dir * 5,0,0), 0.1, 0.8, 40.0, true)
