extends Node3D

const PLAYER_REF :Resource= preload("res://scenes/player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_player("hola_mundo")

func goal_scored(goaler : Player, amount : int) -> void:
	print(goaler, " MADE %s GOALLLLL, " %[amount])

# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass

@warning_ignore("unused_parameter")
func add_player(id :String) -> void:
	var player_inst :Player= PLAYER_REF.instantiate()
	add_child(player_inst)
	player_inst.name = Online.name_id
	player_inst.global_position.y += 5
