##the is the Skill Template, a resource which ill use to make skills easier to manage, heavily
##relying on SB and the execute function
@tool
extends Resource
class_name Skill

signal modified

##the skill name
@export var skill_name := "":
	set(value):
		skill_name = value
		modified.emit()
##how much one gotta wait for it to be used again in seconds
@export var cooldown_in_seconds := 1.0:
	set(value):
		cooldown_in_seconds = value
		modified.emit()
##the key that will activate this skill
@export var key_bind := "":
	set(value):
		key_bind = value
		modified.emit()
##this text is meant to give information to the player, mainly what the move does
@export var top_text := "":
	set(value):
		top_text = value
		modified.emit()
##this text is meant to give information to the player, mainly how the move is usable
@export var bottom_text := "":
	set(value):
		bottom_text = value
		modified.emit()

##this group is the one that determind when a move can be used using conditions of the player
@export_group("conditions")
#region ball conditions
@export_subgroup("ball_conditions")
##this move can be used if u have possesion of the ball
@export var on_ball := true
##this move can be used if u DONT have possesion of the ball
@export var off_ball := true
##this move can be used if ur team have possesion of the ball
@export var ally_possesion := true
##this move can be used if the enemy team have possesion of the ball
@export var enemy_possesion := true
##this move can be used if the ball is in the distance specified
@export_enum("none", "close", "far", "very_far") var distance_needed := "none"
##this move can be used if u were the last on possesion of the ball
@export var last_owner_of_ball := true
#endregion
#region player conditions
@export_subgroup("player_conditions")
##this move can be used when the player is on the ground
@export var on_ground := true
##this move can be used when the player is NOT on the ground
@export var on_air := true
##this move can be used when the player is using an skill or doing an action, cancelling it in the process
@export var mid_skill := false
#endregion

func check_for_execution() -> void:
	pass

func execute() -> void:
	pass
