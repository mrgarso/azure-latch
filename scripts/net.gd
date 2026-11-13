extends Node3D
class_name Net

@onready var field : Field = get_tree().current_scene
@export var reset_ball := false
@export var ball_reset_position := Vector3.ZERO
@export var default_goal_value := 1
@export var gk_bot: Player
@export var gk_dive_area := 4.0
@export var gk_threshold := Vector3(gk_dive_area,100,gk_dive_area)
@export var gk_ideal_pos: Marker3D
@export var react_time := 0.25
@export var distance_react_scale := 0.0003
var ball_to_follow : Ball = null
var gk_in_area := true
var point_selected := 0
var goal_value := 1
var saving := false

func _ready() -> void:
	field.ball_kicked.connect(predict_shot)
	ball_to_follow = field.match_ball

func predict_shot(traj:PackedVector3Array) -> void:
	var saved_points: PackedVector3Array
	var ball_pos := field.match_ball.global_position
	var gk_pos := gk_bot.global_position
	var radius_sq := gk_dive_area * gk_dive_area
	
	for point in traj:
		if point.distance_squared_to(gk_pos) <= radius_sq:
			saved_points.append(point)
			break
	if !saved_points.is_empty():
		var time := gk_pos.distance_squared_to(ball_pos) * distance_react_scale
		print(time)
		await get_tree().create_timer(time).timeout
		gk_dive_from_traj(saved_points)

func gk_dive_from_traj(traj:PackedVector3Array) -> void:
	print("predict!")
	saving = true
	var average_coords := Vector3()
	for i in traj:
		average_coords += i
	var ball_pos := field.match_ball.global_position
	var gk_pos := gk_bot.global_position
	average_coords /= traj.size()
	gk_bot.look_at(Vector3(average_coords.x, gk_bot.global_position.y, average_coords.z))
	await gk_bot.moves.gk_tackles(0.0, true, gk_pos.distance_squared_to(ball_pos) * distance_react_scale * 750)
	gk_bot.rotation = Vector3.ZERO
	saving = false

func gk_dive(dir:Vector3) -> void:
	saving = true
	gk_bot.look_at(Vector3(dir.x, gk_bot.global_position.y, dir.z))
	var ball_pos := field.match_ball.global_position
	var gk_pos := gk_bot.global_position
	await gk_bot.moves.gk_tackles(0.0, true, gk_pos.distance_squared_to(ball_pos) * distance_react_scale * 750)
	gk_bot.rotation = Vector3.ZERO
	saving = false

func _physics_process(delta: float) -> void:
	if !field.match_ball or saving:
		return
	
	var ball_pos := field.match_ball.global_position
	var gk_pos := gk_bot.global_position
	
	var ball := field.match_ball
	if ball.current_owner == null and ball_pos.distance_squared_to(gk_pos) <= 35.0 and \
	ball.velocity.dot(ball_pos.direction_to(gk_pos)) > 5.0:
		saving = true
		await gk_dive(ball_pos)
		return
	
	var look_dir := Vector3(ball_pos.x, gk_pos.y, ball_pos.z)
	if gk_bot.global_position.distance_squared_to(look_dir) > 0.0001:
		gk_bot.look_at(look_dir)
	
	var target := Vector3(
		clampf(ball_pos.x, global_position.x - gk_dive_area * 1.7, global_position.x + gk_dive_area * 1.7),
		gk_pos.y,
		clampf(ball_pos.z, global_position.z - gk_dive_area, global_position.z + gk_dive_area)
	)
	
	
	gk_bot.global_position.x = clampf(gk_pos.x, global_position.x - gk_dive_area * 1.7, global_position.x + gk_dive_area * 1.7)
	gk_bot.global_position.z = clampf(gk_pos.z, global_position.z - gk_dive_area, global_position.z + gk_dive_area)
	var local_offset := gk_bot.global_basis.inverse() * ((target - gk_pos) / 5.0) * 0.5
	SB.velocity(gk_bot, false, local_offset, delta, 0.9, 40.0, true)

func _on_goal_area_area_entered(area: Area3D) -> void:
	var target := area.get_parent()
	if target is not Ball: return
	target = target as Ball
	var last_owner : Player = target.last_owner
	var dir_to_owner := global_position.direction_to(last_owner.global_position)
	target.velocity = Vector3.ZERO
	target.apply_impulse((dir_to_owner + Vector3(0,0.12,0)) * 50.0)
	field.goal(last_owner, goal_value, true, 0.0)
