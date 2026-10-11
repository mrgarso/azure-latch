class_name IsValidTargetBlock
extends SkillBuilderBlock

@export var include_ball_holder := false
@export var include_not_ball_holder := true
@export var include_teammates := false
@export var include_enemies := true

# Filled after run().
var last_result := false

func run(parent : Player = null, target : Player = null) -> void:
	last_result = SB._is_valid_target(target, parent, include_ball_holder, \
			include_not_ball_holder, include_teammates, include_enemies)
