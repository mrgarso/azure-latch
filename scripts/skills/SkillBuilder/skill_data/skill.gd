##the is the Skill Template, a resource which ill use to make skills easier to manage, heavily
##relying on SB and the execute function
@tool
extends Resource
class_name Skill

signal modified
signal cooldown(value, name)


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

@export var script_to_trigger : Script

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

@export_group("funi stuff :p")
##spam the heck outta the skill
@export var no_cooldown := false

var current_cooldown := 0.0

func check_for_execution(player : Player) -> void:
	if can_execute(player):
		execute(player)

func can_execute(player : Player) -> bool:
	var blocked: Array[String] = []
	
	if !on_ball: blocked.append("on_ball")
	if !off_ball: blocked.append("off_ball")
	if !ally_possesion: blocked.append("ally_possesion")
	if !enemy_possesion: blocked.append("enemy_possesion")
	if !last_owner_of_ball: blocked.append("last_owner_of_ball")
	if !on_ground: blocked.append("on_ground")
	if !on_air: blocked.append("on_air")
	if !mid_skill: blocked.append("mid_skill")
	
	for situation in blocked:
		if player.check_conditions(situation):
			return false
	return true

func execute(player : Player) -> void:
	if script_to_trigger != null:
		if current_cooldown > 0.0:
			print("NO SPAMEES")
			return
		await script_to_trigger.use(player)
		var end_msec := Time.get_ticks_msec() + int(cooldown_in_seconds * 1000.0)
		current_cooldown = cooldown_in_seconds
		while current_cooldown > 0.0:
			await (Engine.get_main_loop() as SceneTree).process_frame
			if no_cooldown:
				current_cooldown = 0.0
			else:
				current_cooldown = (end_msec - Time.get_ticks_msec()) / 1000.0
			cooldown.emit(current_cooldown, skill_name)
