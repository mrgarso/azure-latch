class_name TackleBlock
extends SkillBuilderBlock

@export var tackle := true
@export var reset_pos := false
@export_enum("none","right","left") var side_dir := "none"

func run(parent : Player = null, target : Player = null) -> void:
	await SB.tackle(parent, tackle, reset_pos, side_dir)
