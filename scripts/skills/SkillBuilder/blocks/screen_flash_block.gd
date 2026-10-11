class_name ScreenFlashBlock
extends SkillBuilderBlock

@export var color := Color(1, 1, 1, 1)
@export var duration := 1.0

func run(parent : Player = null, target : Player = null) -> void:
	SB.screen_flash(parent, color, duration)
