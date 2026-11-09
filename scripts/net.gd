extends Node3D
class_name Net

@export var reset_ball := false
@export var ball_reset_position := Vector3.ZERO
@onready var root := get_tree().current_scene

func _ready() -> void:
	pass


func _on_goal_area_area_entered(area: Area3D) -> void:
	var target := area.get_parent()
	if target is not Ball: return
	target = target as Ball
	root.goal_scored(target.last_owner, 1)
