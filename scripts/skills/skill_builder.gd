extends Node


func velocity(target: Player,fade_out := false, direction := Vector3.ZERO, duration := 1.0, decay := 0.99, custom_gravity :float= target.gravity, override := false) -> void:
	var imp := Impulse.new()
	if custom_gravity != target.gravity:
		target.current_gravity = custom_gravity
	if direction.y != 0:
		target.velocity.y = 0.0
	imp.vec = direction
	target.impulses.append(imp)
	if fade_out:
		for i in (Engine.physics_ticks_per_second * duration):
			imp.vec *= decay
			imp.vec.y -= custom_gravity * (Engine.time_scale/Engine.physics_ticks_per_second) * 4
			if override:
				target.velocity = imp.vec.x * target.sides + imp.vec.z * target.forw + ((max(imp.vec.y, target.velocity.y) - custom_gravity) * target.up) 
				print((imp.vec.y - custom_gravity) * target.up)
			if imp.cleared:
				break
			await get_tree().create_timer(Engine.time_scale / Engine.physics_ticks_per_second).timeout
	else:
		for i in (Engine.physics_ticks_per_second * duration):
			if override:
				target.velocity = imp.vec.x * target.sides + imp.vec.z * target.forw + ((imp.vec.y - custom_gravity) * target.up) 
			if imp.cleared:
				break
			await get_tree().create_timer(Engine.time_scale / Engine.physics_ticks_per_second).timeout
	target.impulses.erase(imp)
	target.current_gravity = target.gravity

func clear_velocities(target : Player) -> void:
	var impulses := target.impulses
	for i in impulses:
		i.cleared = true

func wait(frames := 60, speed := 1.0) -> void:
	for i in frames:
		await get_tree().create_timer(Engine.time_scale / Engine.physics_ticks_per_second * speed).timeout

func afterimage(target: Player, quantity := 5, in_between := 0.1, duration := 1.0, custom_color := Color(1,1,1,1), offset := Vector3(0,0,0)) -> void:
	var source: MeshInstance3D = target.get_node("MeshInstance3D")
	var multi := MultiMeshInstance3D.new()
	multi.name = str("afterimages of ", target.name)
	multi.multimesh = MultiMesh.new()
	multi.multimesh.mesh = source.mesh.duplicate()
	multi.multimesh.mesh.surface_set_material(0, StandardMaterial3D.new())
	multi.multimesh.use_colors = true
	var mat := StandardMaterial3D.new()
	mat.albedo_color = custom_color
	
	mat.vertex_color_use_as_albedo = true
	multi.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multi.multimesh.instance_count = quantity
	multi.multimesh.mesh.surface_set_material(0, mat)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	get_tree().current_scene.add_child(multi)
	for i in quantity:
		if i >= multi.multimesh.instance_count:
			break
		var desired_transform := target.global_transform
		desired_transform.origin += offset
		multi.multimesh.set_instance_transform(i, desired_transform)
		multi.multimesh.visible_instance_count = i + 1
		multi.multimesh.set_instance_color(i, custom_color)
		await get_tree().create_timer(in_between).timeout
	var tween := create_tween()
	tween.set_parallel(true)
	var fade_color := Color(custom_color.r, custom_color.g, custom_color.b, 0.0)
	for i in quantity:
		if i >= multi.multimesh.instance_count:
			break
		
		tween.tween_method(
			func(c: Color): multi.multimesh.set_instance_color(i, c),
			custom_color, fade_color, duration
		)
	await tween.finished
	multi.queue_free()

func clear_afterimages(target) -> void:
	var multi :MultiMeshInstance3D= get_tree().current_scene.get_node(str("afterimages of ", target.name))
	if multi == null:
		return
	multi.multimesh.instance_count = multi.multimesh.visible_instance_count

func fov_change(target: Player, from := 70, to := 70, duration := 1.0) -> void:
	for i in get_tree().get_processed_tweens():
		if i.is_valid():
			i.kill()
	var tween := create_tween()
	var camera: Camera3D = target.get_node("shoulder/SpringArm3D/Camera3D")
	camera.fov = from
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

func kick(target: Player = null, direction := Vector3(), force := 70.0, \
unattach := true, speed := 1.0, show_traj := false, \
curvature_dir := Vector3.ZERO,  time_for_curve := 0.0, curvature_force := 0.0) -> void:
	var subject: Ball = target.ball
	var aim_dir := (target.transform.basis * direction).normalized()
	var final_direction := -aim_dir * force
	subject.velocity = Vector3.ZERO
	var ball_traj_range := 240
	var ball_traj_delta := 1.0 / Engine.physics_ticks_per_second
	var ball_traj_width := 0.05
	show(subject.trajectory_mesh)
	@warning_ignore("integer_division")
	var ball_traj := subject.predict_trajectory(subject.global_position, final_direction, \
	ball_traj_range / Engine.physics_ticks_per_second, ball_traj_delta, speed, \
	curvature_dir, time_for_curve, curvature_force)
	if show_traj:
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
		subject.apply_impulse(final_direction, curvature_dir, time_for_curve, curvature_force)
		target.ball = null

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

enum HitboxTargets {
	MAP = 1,
	PLAYERS = 2,
	BALL = 3
}

func hitbox(parent: Player = null, size := Vector3.ONE * 10, offset := Vector3.ZERO, duration := 1.0, target := HitboxTargets.BALL) -> Player:
	var area := Area3D.new()
	var collision := CollisionShape3D.new()
	@warning_ignore("unused_variable")
	var collided := false
	var target_hit :Node3D= null
	collision.shape = BoxShape3D.new() as BoxShape3D
	collision.position = offset
	collision.debug_color = Color(0.5,0,1)
	collision.shape.size = size
	collision.disabled = !parent.can_grab_ball
	area.set_collision_mask_value(1, false)
	area.set_collision_mask_value(target, true)
	area.add_child(collision)
	parent.add_child(area)
	for i in Engine.physics_ticks_per_second * duration:
		area.global_position = parent.global_position
		collision.disabled = !parent.can_grab_ball
		if area.get_overlapping_areas():
			collided = true
			target_hit = area.get_overlapping_areas()[0].get_parent()
			break
		await wait(1)
	delete(area, 0.0)
	if target_hit is Ball:
		parent.ball = target_hit
	return null

func player_state(target : Player = null, grab_ball := true, iframes := false, duration := 1.0) -> void:
	var before := {
		"grab": target.can_grab_ball,
		}
	target.can_grab_ball = grab_ball
	await wait(duration * 60)
	target.can_grab_ball = before.grab
