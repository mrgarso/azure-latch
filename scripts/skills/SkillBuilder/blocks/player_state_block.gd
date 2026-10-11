class_name PlayerStateBlock
extends SkillBuilderBlock

@export var grab_ball := true
@export var iframes := false
@export var duration := 1.0
## If off, the next block runs right away and the state resets later.
@export var wait_until_done := false

func run(parent : Player = null, target : Player = null) -> void:
	if wait_until_done:
		await SB.player_state(parent, grab_ball, iframes, duration)
	else:
		SB.player_state(parent, grab_ball, iframes, duration)
