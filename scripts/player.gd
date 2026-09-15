extends CharacterBody3D
class_name Player

@export var speed := 20.0
@export var accel := 10.0
@export var frict := 10.0
@export var jump_speed := 35.0
@export var gravity := 40.0
@export var ball_holder: Node3D
@export var spring_arm_3d: SpringArm3D
@export var grab_ball_area: Area3D
@export var fps_label: Label

var can_move := true:
	set(value):
		can_move = value
		direction = Vector2.ZERO
var using_move := false
var iframes := false
var direction := Vector2.ZERO
var forw := Vector3.ZERO
var sides := Vector3.ZERO
var movement := Vector3.ZERO
var impulses: Array[Impulse] = []

func _physics_process(delta: float) -> void:
	fps_label.text = "fps = " + str(Engine.get_frames_per_second())
	forw = transform.basis.z
	sides = transform.basis.x

	var impulse_sum := Vector3.ZERO
	for imp in impulses:
		impulse_sum += imp.vec

	if using_move:
		direction = Vector2(impulse_sum.x, impulse_sum.z)
	elif can_move:
		direction = Input.get_vector("a", "d", "w", "s")
		if is_on_floor() and Input.is_action_pressed("space"):
			velocity.y = jump_speed

	movement = ((direction.x * sides) + (direction.y * forw)) * speed
	if direction:
		velocity.x = lerp(velocity.x, movement.x, delta * accel)
		velocity.z = lerp(velocity.z, movement.z, delta * accel)
	else:
		velocity.x = lerp(velocity.x, 0.0, delta * frict)
		velocity.z = lerp(velocity.z, 0.0, delta * frict)

	#velocity.y = impulse_sum.y * delta * 3
	#velocity.y = lerp(velocity.y, impulse_sum.y, delta * 3)
	if impulse_sum.y:
		velocity.y = lerp(velocity.y, impulse_sum.y * speed, delta * accel)
	if not is_on_floor():
		velocity.y -= gravity * delta * 4

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	pass
