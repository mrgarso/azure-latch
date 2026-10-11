class_name HitboxDetailedBlock
extends SkillBuilderBlock

@export var size := Vector3.ONE * 10
@export var offset := Vector3.ZERO
@export var duration := 1.0
@export var hit_target := SkillBuilder.HitboxTargets.BALL
@export var include_ball_holder := false
@export var include_not_ball_holder := true
@export var include_teammates := false
@export var include_enemies := true

# Filled after run(): "collided", "velocity", "position", "class".
var last_result := {}

func run(parent : Player = null, target : Player = null) -> void:
	last_result = await SB.hitbox_detailed(parent, size, offset, duration, hit_target, \
			include_ball_holder, include_not_ball_holder, include_teammates, include_enemies)
