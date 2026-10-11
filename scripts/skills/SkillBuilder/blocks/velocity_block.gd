class_name VelocityBlock
extends SkillBuilderBlock

@export var fade_out := false
@export var direction := Vector3.ZERO
@export var duration := 1.0
@export var decay := 0.99
## If off, the player's normal gravity is used.
@export var use_custom_gravity := false
@export var custom_gravity := 0.0
@export var override := false
@export var reset_y := false
## If off, the next block runs right away while the velocity keeps going.
@export var wait_until_done := false

func run(parent : Player = null, target : Player = null) -> void:
	var gravity : float = custom_gravity if use_custom_gravity else parent.gravity
	if wait_until_done:
		await SB.velocity(parent, fade_out, direction, duration, decay, gravity, override, reset_y)
	else:
		SB.velocity(parent, fade_out, direction, duration, decay, gravity, override, reset_y)
