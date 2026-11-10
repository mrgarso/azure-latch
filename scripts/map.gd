extends Node3D
class_name Field

const PLAYER_REF :Resource= preload("res://scenes/player.tscn")
@export var match_seconds := 360.0
@onready var current_match_seconds := match_seconds
var goal_scored := false
var children := []
var positions := []

func _physics_process(delta: float) -> void:
	current_match_seconds -= delta
	for i in children:
		if i is not Player: continue
		i = i as Player
		i.ui.update_labels_time(current_match_seconds)

func _ready() -> void:
	get_all_children()
	add_player("hola_mundo")

func get_all_children() -> void:
	await get_tree().physics_frame
	for i in get_child_count():
		var current_child := get_child(i)
		if current_child.get_script() == null: continue
		children.append(current_child)

func goal(goaler : Player, amount : int, reset := false, \
reset_time := 1.0) -> void:
	#print(goaler, " MADE %s GOALLLLL, " %[amount])
	if !reset:return
	await get_tree().create_timer(reset_time).timeout
	for i in children:
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
