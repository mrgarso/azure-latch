class_name ClearVelocitiesBlock
extends SkillBuilderBlock

func run(parent : Player = null, target : Player = null) -> void:
	SB.clear_velocities(parent)
