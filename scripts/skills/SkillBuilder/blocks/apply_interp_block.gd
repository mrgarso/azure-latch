class_name ApplyInterpBlock
extends SkillBuilderBlock

@export var kind := SkillBuilder.Interp.LINEAR
@export_range(0.0, 1.0, 0.01) var t := 0.0

# This function returns a value, so the result is stored here for other code to read.
var last_result := 0.0

func run(parent : Player = null, target : Player = null) -> void:
	last_result = SB.apply_interp(kind, t)
