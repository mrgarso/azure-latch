extends Node3D
class_name Ball

@export var velocity := Vector3.ZERO
@export var gravity_force := Vector3(0, -30, 0)
##if radius is equals to 0.0, it will use its mesh radius instead
@export var radius := 0.0
@export var speed_scale := 1.0
@export var restitution = 0.5
@export var air_friction := 0.96
@export var mesh: MeshInstance3D
@export var detection: Area3D
@export var trajectory_mesh: MeshInstance3D
var current_owner : Player = null
var last_owner : Player = null

func _ready() -> void:
	var area : CollisionShape3D = detection.get_child(0)
	area.shape.radius = mesh.mesh.radius
	if radius == 0.0:
		radius = mesh.mesh.radius

func simulate_step(pos:= Vector3(0,0,0), vel:= Vector3(0,0,0), delta:= 0.0, predicting := false) -> Dictionary:
	delta *= speed_scale
	var decay = pow(air_friction, delta)
	vel.x *= decay
	vel.z *= decay
	if current_owner == null or predicting:
		vel += gravity_force * delta
	
	var steps := 4
	var step_delta = delta / steps
	
	for i in steps:
		var motion = vel * step_delta
		var motion_length = motion.length()
		if motion_length < 0.001:
			continue
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(
			pos,
			pos + motion.normalized() * (motion.length() + radius)
		)
		var result = space_state.intersect_ray(query)
		if result:
			pos = result.position - motion.normalized() * radius
			vel = vel.bounce(result.normal) * restitution
		else:
			pos += motion
		
	return {"position": pos, "velocity": vel}

func _physics_process(delta: float) -> void:
	var result = simulate_step(global_position, velocity, delta)
	global_position = result.position
	velocity = result.velocity

func predict_trajectory(start_pos:= Vector3(0,0,0), start_vel:= Vector3(0,0,0), seconds:= 1.0, dt:= (1.0/60.0), speed := 1.0) -> PackedVector3Array:
	speed_scale = speed
	var points := PackedVector3Array()
	var pos := start_pos
	var vel := start_vel
	points.append(pos)
	var iterations = int(seconds / dt)
	for i in iterations:
		var result = simulate_step(pos, vel, dt * speed, true)
		pos = result.position
		vel = result.velocity
		points.append(pos)
		
	return points

func apply_impulse(direction := Vector3.ZERO):
	velocity += direction
