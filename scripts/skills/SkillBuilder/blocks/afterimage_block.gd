class_name AfterimageBlock
extends SkillBuilderBlock

@export var quantity := 5
@export var in_between := 0.1
@export var duration := 1.0
@export var custom_color := Color(1, 1, 1, 1)
@export var offset := Vector3.ZERO
## If off, the next block runs right away while the afterimages play out.
@export var wait_until_done := false

func run(parent : Player = null, target : Player = null) -> void:
	if wait_until_done:
		await SB.afterimage(parent, quantity, in_between, duration, custom_color, offset)
	else:
		SB.afterimage(parent, quantity, in_between, duration, custom_color, offset)
