class_name FovChangeBlock
extends SkillBuilderBlock

@export var from_fov := 70.0
@export var to_fov := 70.0
@export var duration := 1.0
@export var kind := SkillBuilder.Interp.LINEAR

func run(parent : Player = null, target : Player = null) -> void:
	SB.fov_change(parent, from_fov, to_fov, duration, kind)
