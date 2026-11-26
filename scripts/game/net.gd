extends Node3D
class_name Net

@onready var field : Field = get_tree().current_scene
@export var reset_ball := false
@export var ball_reset_position := Vector3.ZERO
@export var default_goal_value := 1
@export var gk_bot: Player
@export var gk_dive_area := 4.0
@export var gk_threshold := Vector3(gk_dive_area,100,gk_dive_area)
@export var react_time := 0.25
@export var distance_react_scale := 0.0003
var ball_to_follow : Ball = null
var gk_in_area := true
var point_selected := 0
var goal_value := 1
var throwing := false
var saving := false
var players : Array[Player] 
var nearest_player : Player = null


func _ready() -> void:
	find_nearest_player()
	field.ball_kicked.connect(predict_shot)
	ball_to_follow = field.match_ball

func find_nearest_player(team_needed := "") -> void:
	players = field.get_players()
	nearest_player = null
	if team_needed == "":
		print("everyone gets it")
		for i in players:
			if nearest_player == null:
				nearest_player = i
			else:
				if gk_bot.global_position.distance_squared_to(i.global_position) < \
				gk_bot.global_position.distance_squared_to(nearest_player.global_position):
					nearest_player = i
	else:
		print("checking for teammate")
		for i in players:
			if i.team != team_needed: continue
			if nearest_player == null:
				nearest_player = i
			else:
				if gk_bot.global_position.distance_squared_to(i.global_position) < \
				gk_bot.global_position.distance_squared_to(nearest_player.global_position):
					nearest_player = i

func predict_shot(traj:PackedVector3Array) -> void:
	if saving: return
	var saved_points: PackedVector3Array
	var ball_pos := field.match_ball.global_position
	var gk_pos := gk_bot.global_position
	var radius_sq := gk_dive_area * gk_dive_area
	
	for point in traj:
		if point.distance_squared_to(global_position) <= radius_sq * 1.6:
			saved_points.append(point)
			break
	if !saved_points.is_empty():
		var time := (gk_pos.distance_squared_to(ball_pos) * distance_react_scale) * 1.125
		await get_tree().create_timer(time).timeout
		await gk_dive_from_traj(saved_points)

func gk_dive_from_traj(traj:PackedVector3Array) -> void:
	if saving or throwing: return
	saving = true
	var average_coords := Vector3()
	for i in traj:
		average_coords += i
	var ball_pos := field.match_ball.global_position
	var gk_pos := gk_bot.global_position
	average_coords /= traj.size()
	gk_bot.look_at(Vector3(average_coords.x, gk_bot.global_position.y, average_coords.z))
	await gk_bot.moves.gk_tackles(0.0, true, gk_pos.distance_squared_to(ball_pos) * distance_react_scale * 300)
	gk_bot.rotation = Vector3.ZERO
	saving = false

func gk_dive(dir:Vector3) -> void:
	saving = true
	gk_bot.look_at(Vector3(dir.x, gk_bot.global_position.y, dir.z))
	var ball_pos := field.match_ball.global_position
	var gk_pos := gk_bot.global_position
	await gk_bot.moves.gk_tackles(0.0, true, gk_pos.distance_squared_to(ball_pos) * distance_react_scale * 900)
	gk_bot.rotation = Vector3.ZERO
	saving = false

func _physics_process(delta: float) -> void:
	if throwing:
		find_nearest_player()
		gk_bot.look_at(nearest_player.global_position)
		return
	if !field.match_ball or saving or gk_bot.stun_time > 0.0 or gk_bot.using_move:
		return
	
	
	var ball := field.match_ball
	var ball_pos := ball.global_position
	var gk_pos := gk_bot.global_position
	
	if gk_bot.ball != null: 
		gk_bot.ball.global_position = gk_bot.ball_holder.global_position
	
	if ball_pos.distance_squared_to(global_position) <= 215.0 and gk_bot.ball == null:
		await gk_dive(ball_pos)
		if gk_bot.ball != null:
			await get_tree().create_timer(0.5).timeout
		return
	
	var look_dir := Vector3(ball_pos.x, gk_pos.y, ball_pos.z)
	if gk_bot.global_position.distance_squared_to(look_dir) > 0.0002:
		gk_bot.look_at(look_dir)
	
	var target := Vector3(
		clampf(ball_pos.x, global_position.x - gk_dive_area * 1.7, global_position.x + gk_dive_area * 1.7),
		gk_pos.y,
		clampf(ball_pos.z, global_position.z - gk_dive_area, global_position.z + gk_dive_area)
	)
	
	var local_offset := gk_bot.global_basis.inverse() * ((target - gk_pos) / 5.0) * 0.25
	if gk_bot.ball == null:
		gk_bot.global_position.x = lerp(gk_bot.global_position.x ,clampf(gk_pos.x, global_position.x - gk_dive_area * 1.7, global_position.x + gk_dive_area * 1.7), delta * 2)
		gk_bot.global_position.z = lerp(gk_bot.global_position.z ,clampf(gk_pos.z, global_position.z - gk_dive_area, global_position.z + gk_dive_area), delta * 2)
		SB.velocity(gk_bot, false, local_offset, delta, 0.9, 40.0, true)
	else:
		gk_bot.global_position = lerp(gk_bot.global_position, global_position, delta * 5)
		if gk_bot.global_position.distance_to(global_position) < 10:
			gk_throw()
	

func gk_throw():
	find_nearest_player()
	throwing = true
	var ball := gk_bot.ball
	ball.can_goal = false
	ball.can_grab = false
	print(nearest_player)
	for i in 3:
		gk_bot.look_at(nearest_player.global_position)
	await gk_bot.moves.gk_throw(gk_bot.global_position.distance_to(nearest_player.global_position) * 1.5)
	await get_tree().create_timer(0.5).timeout
	throwing = false
	ball.can_goal = true
	ball.can_grab = true
	return

func _on_goal_area_area_entered(area: Area3D) -> void:
	var target := area.get_parent()
	if target is not Ball: return
	target = target as Ball
	target.velocity = Vector3.ZERO
	throwing = false
	saving = false
	if target.current_owner != null: return
	if !target.can_goal: return
	gk_bot.ball = target
	await gk_throw()
	await SB.wait(40)
