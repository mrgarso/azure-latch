class_name HitboxBlock
extends SkillBuilderBlock

@export var size := Vector3.ONE * 10
@export var offset := Vector3.ZERO
@export var duration := 1.0
@export var hit_target := SkillBuilder.HitboxTargets.BALL
@export var include_ball_holder := false
@export var include_not_ball_holder := true
@export var include_teammates := false
@export var include_enemies := true
## If off, the next block runs right away while the hitbox is active.
@export var wait_until_done := true

func run(parent : Player = null, target : Player = null) -> void:
	if wait_until_done:
		await SB.hitbox(parent, size, offset, duration, hit_target, include_ball_holder, \
				include_not_ball_holder, include_teammates, include_enemies)
	else:
		SB.hitbox(parent, size, offset, duration, hit_target, include_ball_holder, \
				include_not_ball_holder, include_teammates, include_enemies)
