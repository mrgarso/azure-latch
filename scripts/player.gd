extends CharacterBody3D
class_name Player

@export var speed := 20.0
@export var accel := 10.0
@export var frict := 10.0
@export var ball_holder: Node3D
@export var spring_arm_3d: SpringArm3D
@export var grab_ball_area: Area3D
@export var volley_area: Area3D
@export var ball_aim: MeshInstance3D
var can_move := true:
	set(value):
		can_move = value
		direction = Vector2.ZERO
var using_move := false
var iframes := false
var current_speed := 0.0
var direction := Vector2.ZERO
var forw := Vector3.ZERO
var sides := Vector3.ZERO
var movement := Vector3.ZERO
var impulses : Array[Impulse] = []

func _ready() -> void:
	current_speed = speed

func _physics_process(delta: float) -> void:
	forw = transform.basis.z
	sides = transform.basis.x
	if using_move:
		var summed := Vector2.ZERO
		for imp in impulses:
			summed += imp.vec
		direction = summed
	elif can_move:
		direction = Input.get_vector("a","d","w","s")
	movement = ((direction.x * sides) + (direction.y * forw)) * speed
	if direction:
		velocity = lerp(velocity,Vector3(movement.x,velocity.y,movement.z),delta * accel)
	else:
		velocity = lerp(velocity,Vector3(0,velocity.y,0),delta * frict)
	
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	pass
