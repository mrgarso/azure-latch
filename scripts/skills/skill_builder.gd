extends Node


func velocity(target: Player, direction := Vector3.ZERO, duration := 1.0, decay := 0.99) -> void:
	var imp := Impulse.new()
	if direction.y != 0:
		target.velocity.y = 0.0
	imp.vec = direction
	target.impulses.append(imp)
	for i in (Engine.physics_ticks_per_second * duration):
		imp.vec *= decay
		await get_tree().create_timer(Engine.time_scale / Engine.physics_ticks_per_second).timeout
	target.impulses.erase(imp)

func wait(frames := 60, speed := 1.0) -> void:
	for i in frames:
		await get_tree().create_timer(Engine.time_scale / Engine.physics_ticks_per_second * speed).timeout

func afterimage(target: Player, quantity := 5, in_between := 0.1, duration := 1.0, custom_color := Color(1,1,1,1), offset := Vector3(0,0,0)) -> void:
	var source: MeshInstance3D = target.get_node("MeshInstance3D")
	for i in quantity:
		var clone := source.duplicate() as MeshInstance3D
		target.get_parent().add_child(clone)
		var mat: StandardMaterial3D = clone.get_active_material(0)
		if mat == null:
			mat = StandardMaterial3D.new()
		elif mat is BaseMaterial3D:
			mat = mat.duplicate()
		else:
			clone.queue_free()
			continue
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_HASH
		clone.set_surface_override_material(0, mat)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = custom_color
		clone.global_transform = target.global_transform
		clone.global_position += (target.transform.basis * -offset)
		clone.name = "afterimage %d" % i
		clone.top_level = true
		var tween := clone.create_tween()
		tween.tween_property(clone, "transparency", 1.0, duration)
		tween.tween_callback(clone.queue_free)
		await get_tree().create_timer(in_between).timeout

func fov_change(target: Player, from := 70, to := 70, duration := 1.0) -> void:
	var camera: Camera3D = target.get_node("shoulder/SpringArm3D/Camera3D")
	camera.fov = from
	var tween := create_tween()
	tween.tween_property(camera, "fov", to, duration)

func screen_flash(target: Player, color := Color(1,1,1,1), duration := 1.0) -> void:
	var screen: CanvasLayer = target.get_node("screen_effects")
	for i in screen.get_child_count():
		var subject: Control = screen.get_child(i)
		if subject is TextureRect:
			subject.self_modulate = color
			var tween := create_tween()
			tween.tween_property(subject, "self_modulate", Color(color.r, color.g, color.b, 0), duration)

func counter() -> void:
	pass

func kick(target: Player = null, direction := Vector3(), force := 70.0, unattach := true, speed := 1.0) -> void:
	var subject: Ball = target.grab_ball_area.ball
	show(subject.trajectory_mesh)
	var aim_dir := (target.transform.basis * direction).normalized()
	var final_direction := -aim_dir * force
	var ball_traj_range := 240
	var ball_traj_delta := 1.0 / Engine.physics_ticks_per_second
	var ball_traj_width := 0.05

	@warning_ignore("integer_division")
	var ball_traj := subject.predict_trajectory(subject.global_position, final_direction, ball_traj_range / Engine.physics_ticks_per_second, ball_traj_delta, speed)

	var traj_shortened := 2.5
	var step_size := int(pow(2, traj_shortened))

	var traj_ball_traj := PackedVector3Array()
	for i in range(0, ball_traj.size(), step_size):
		traj_ball_traj.append(ball_traj[i])
	subject.trajectory_mesh.mesh = subject.build_traj_mesh(traj_ball_traj, ball_traj_width)
	subject.trajectory_mesh.visible = true

	if unattach:
		subject.current_owner = null
		subject.last_owner = target
		subject.apply_impulse(final_direction)
		target.grab_ball_area.ball = null
		fade_and_hide(subject.trajectory_mesh, 2.0)

func fade_and_hide(mesh_inst: MeshInstance3D, duration := 0.5) -> void:
	var mat := mesh_inst.material_override as StandardMaterial3D
	if mat == null:
		return
	mat.albedo_color.a = 1.0
	var tween := create_tween()
	tween.tween_property(mat, "albedo_color:a", 0.0, duration)
	tween.tween_callback(func(): mesh_inst.visible = false)

func show(mesh_inst: MeshInstance3D) -> void:
	var mat := mesh_inst.material_override as StandardMaterial3D
	if mat == null:
		return
	mat.albedo_color.a = 1.0
	var tween := create_tween()
	tween.tween_property(mat, "albedo_color:a", 1.0, 0.0)
	tween.tween_callback(func(): mesh_inst.visible = true)

func delete(target: Node3D, seconds := 0.5) -> void:
	await get_tree().create_timer(seconds).timeout
	target.queue_free()
