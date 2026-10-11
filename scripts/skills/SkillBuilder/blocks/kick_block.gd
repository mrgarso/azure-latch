class_name KickBlock
extends SkillBuilderBlock

@export var direction := Vector3.ZERO
@export var force := 70.0
@export var unattach := true
@export var speed := 1.0
@export var show_traj := false
@export var curvature_dir := Vector3.ZERO
@export var time_for_curve := 0.0
@export var curvature_force := 0.0

func run(parent : Player = null, target : Player = null) -> void:
	SB.kick(parent, direction, force, unattach, speed, show_traj, \
			curvature_dir, time_for_curve, curvature_force)
