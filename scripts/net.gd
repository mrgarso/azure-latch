extends Node3D
class_name Net

@onready var field : Field = get_tree().current_scene
@export var reset_ball := false
@export var ball_reset_position := Vector3.ZERO
@export var default_goal_value := 1
var goal_value := 1

func _ready() -> void:
	pass


func _on_goal_area_area_entered(area: Area3D) -> void:
	var target := area.get_parent()
	if target is not Ball: return
	target = target as Ball
	field.goal(target.last_owner, goal_value, true, 0.0)
