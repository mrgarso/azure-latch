extends CharacterBody3D
class_name Player

@export var speed := 20.0
@export var accel := 10.0
@export var frict := 10.0
var iframes := false
var current_speed := 0.0
var direction := Vector2.ZERO
var forw := Vector3.ZERO
var sides := Vector3.ZERO
var movement := Vector3.ZERO

func _ready() -> void:
	current_speed = speed

func _physics_process(delta: float) -> void:
	forw = transform.basis.z
	sides = transform.basis.x
	movement = (direction.x * sides) * speed + (direction.y * forw) * speed
	if direction:
		velocity = lerp(velocity,Vector3(movement.x,velocity.y,movement.z),delta * accel)
	else:
		velocity = lerp(velocity,Vector3(0,velocity.y,0),delta * frict)
	
	move_and_slide()
	direction = Input.get_vector("a","d","w","s")
