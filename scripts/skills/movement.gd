extends Node

@onready var player :Player= $".."

func _unhandled_key_input(event: InputEvent) -> void:
	if !player.using_move:
		if Input.is_action_just_pressed("e"):
			var dir := Input.get_axis("a","d")
			if dir == 0:
				SB.velocity(get_parent(), true, Vector3(0,0,-50), 0.9, 0.95, 40.0, true)
				return
			SB.velocity(get_parent(), true, Vector3(dir * 80,0,0), 0.1, 0.8, 40.0, true)
