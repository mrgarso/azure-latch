class_name WaitBlock
extends SkillBuilderBlock

@export var time_in_frames := 60
@export var speed := 1.0

func run(parent : Player = null, target : Player = null) -> void:
	await SB.wait(time_in_frames, speed)
