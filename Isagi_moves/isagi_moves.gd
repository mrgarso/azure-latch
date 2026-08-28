extends Node


@export var player: Player

func _unhandled_input(event: InputEvent) -> void:
	if !player.using_move:
		if Input.is_action_just_pressed("1"):
			trigger("MOVE_1")

func trigger(move:String, speed:float=1.0, godmode:bool=false, vulnerable:bool=false):
	get_node(move).use(player, speed, godmode, vulnerable)
