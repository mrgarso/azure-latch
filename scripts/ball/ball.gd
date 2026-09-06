extends Node3D
class_name Ball

@export var velocity := Vector3.ZERO
@export var gravity_force := Vector3(0, -30, 0)
##if radius is equals to 0.0, it will use its mesh radius instead
@export var radius := 0.0
@export var speed_scale := 1.0
@export var restitution = 0.5
@export var air_friction := 0.5
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
	var mat := StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	trajectory_mesh.material_override = mat
	trajectory_mesh.visible = false
	trajectory_mesh.top_level = true
	trajectory_mesh.global_transform = Transform3D.IDENTITY

func simulate_step(pos:= Vector3(0,0,0), vel:= Vector3(0,0,0), delta:= 0.0, predicting := false) -> Dictionary:
	delta *= speed_scale
	var decay = pow(air_friction, delta)
	vel.x *= decay
	vel.z *= decay
	
	var steps := 4
	var step_delta = delta / steps
	if current_owner == null or predicting:
		vel += gravity_force * delta
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
				var bounced := vel.bounce(result.normal)
				var normal_part :Vector3= bounced.dot(result.normal) * result.normal
				var tangent_part := bounced - normal_part
				vel = tangent_part + normal_part * restitution
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

func build_traj_mesh(points: PackedVector3Array, traj_radius := 1.0, sides := 4, color := Color(1,0,1)) -> ArrayMesh:
	if points.size() < 2:
		return ArrayMesh.new()
	
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var last := points.size() - 1
	var rings : Array[PackedVector3Array] = []
	var ring_radii: Array[float] = []
	
	for i in points.size():
		var p := points[i]
		var dir := Vector3()
		if i == 0:
			dir = (points[i + 1] - p).normalized()
		elif  i == last:
			dir = (p - points[i - 1]).normalized()
		else:
			dir = (points[i + 1] - points[i - 1]).normalized()
		var up_ref := Vector3.RIGHT
		if abs(dir.dot(Vector3.UP)) < 0.99:
			up_ref = Vector3.UP
		var right := dir.cross(up_ref).normalized()
		var up := right.cross(dir).normalized()
		
		var safe_radius := traj_radius
		if i > 0 and i < last:
			var curvature_r := local_curvature_radius(points[i - 1], p, points[i + 1])
			safe_radius = min(traj_radius, curvature_r * 0.9)
		ring_radii.append(safe_radius)
		
		var ring := PackedVector3Array()
		for s in sides:
			var angle := (TAU * s)/sides
			var offset :Vector3= (right * cos(angle) + up * sin(angle)) * safe_radius
			ring.append(p + offset)
		rings.append(ring)
	
	for i in rings.size() - 1:
		var ring_a := rings[i]
		var ring_b := rings[i + 1]
		var alpha_a := 1.0 - float(i) / float(last)
		var alpha_b := 1.0 - float(i + 1) / float(last)
		
		for s in sides:
			var s_next := (s + 1) % sides
			
			var a0 := ring_a[s]
			var a1 := ring_a[s_next]
			var b0 := ring_b[s]
			var b1 := ring_b[s_next]
			
			st.set_color(Color(color, alpha_a)); st.add_vertex(a0)
			st.set_color(Color(color, alpha_b)); st.add_vertex(b0)
			st.set_color(Color(color, alpha_a)); st.add_vertex(a1)
			
			st.set_color(Color(color, alpha_a)); st.add_vertex(a1)
			st.set_color(Color(color, alpha_b)); st.add_vertex(b0)
			st.set_color(Color(color, alpha_b)); st.add_vertex(b1)
	st.generate_normals()
	return st.commit()

func apply_impulse(direction := Vector3.ZERO):
	velocity += direction

func local_curvature_radius(p0 := Vector3(), p1 := Vector3(), p2 := Vector3()) -> float:
	var a := p0.distance_to(p1)
	var b := p1.distance_to(p2)
	var c := p2.distance_to(p0)
	var s := (a + b + c) / 2.0
	var area_sq := s * (s - a) * (s - b) * (s - c)
	if area_sq <= 0.0001:
		return INF
	var area := sqrt(area_sq)
	return (a * b * c) / (4.0 * area)
