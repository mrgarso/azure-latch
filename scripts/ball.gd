extends Node3D
class_name Ball

@export var velocity := Vector3.ZERO
@export var gravity_force := Vector3(0, -30, 0)
##if radius is equals to 0.0, it will use its mesh radius instead
@export var radius := 0.0
@export var restitution = 0.5
@export var air_friction := 0.975
@export var mesh: MeshInstance3D
@export var detection: Area3D
var current_owner : Player = null
var last_owner : Player = null

func _ready() -> void:
	var area : CollisionShape3D = detection.get_child(0)
	area.shape.radius = mesh.mesh.radius
	if radius == 0.0:
		radius = mesh.mesh.radius

func _physics_process(delta: float) -> void:
	var decay = pow(air_friction, delta)
	velocity.x *= decay
	velocity.z *= decay
	if current_owner == null:
		velocity += gravity_force * delta
	
	var steps := 4
	var step_delta = delta / steps
	
	for i in steps:
		var motion = velocity * step_delta
		var motion_length = motion.length()
		
		if motion_length < 0.001:
			continue
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(
			global_position,
			global_position + motion.normalized() * (motion.length() + radius)
		)
		var result = space_state.intersect_ray(query)
		if result:
			global_position = result.position - motion.normalized() * radius
			velocity = velocity.bounce(result.normal) * restitution
		else:
			global_position += motion

func apply_impulse(direction := Vector3.ZERO):
	velocity += direction
