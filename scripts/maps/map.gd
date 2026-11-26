extends Node3D
class_name Field

@warning_ignore("unused_signal")
signal ball_kicked(traj : PackedVector3Array)
const PLAYER_REF :Resource= preload("res://scenes/player.tscn")
@onready var current_match_seconds := match_seconds
@export var match_seconds := 360.0
@export var match_ball : Ball = null
var players : Array[Player]
var goal_scored := false
var positions := []

func _physics_process(delta: float) -> void:
	current_match_seconds -= delta
	for i in players:
		@warning_ignore("narrowing_conversion")
		i.ui.update_labels_time(current_match_seconds)

func get_players() -> Array[Player]:
	var list : Array[Player]
	for i in get_child_count():
		var current_child := get_child(i)
		if current_child.get_script() == Player:
			list.append(current_child)
	return list

func _ready() -> void:
	add_player("hola_mundo")

@warning_ignore("unused_parameter")
func goal(goaler : Player, amount : int, reset := false, \
reset_time := 1.0) -> void:
	#print(goaler, " MADE %s GOALLLLL, " %[amount])
	if !reset:return
	await get_tree().create_timer(reset_time).timeout
	for i in players:
		if i.has_method("goal_behaviour"): i.goal_behaviour()

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass

@warning_ignore("unused_parameter")
func add_player(id :String) -> void:
	var player_inst :Player= PLAYER_REF.instantiate()
	add_child(player_inst)
	player_inst.name = Online.name_id
	player_inst.global_position.y += 5
	players = get_players()
	if match_ball == null:
		for i in get_children():
			if i is Ball:
				match_ball = i
				break
