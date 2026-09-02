extends Node


func velocity(target: Player, direction := Vector2(0,0), duration := 1.0, decay := 0.99) -> void:
	var imp := Impulse.new()
	imp.vec = direction
	target.impulses.append(imp)
	for i in (Engine.physics_ticks_per_second * duration):
		imp.vec *= decay
		await get_tree().create_timer(Engine.time_scale / Engine.physics_ticks_per_second).timeout

func wait(frames := 60, speed := 1.0) -> void:
	for i in frames:
		await get_tree().create_timer(Engine.time_scale / Engine.physics_ticks_per_second * speed).timeout

func afterimage(target: Player, quantity := 5, in_between := 0.1, duration := 1.0, custom_color := Color(1,1,1,1), offset := Vector3(0,0,0)) -> void:
	var source: MeshInstance3D = target.get_node("MeshInstance3D")
	for i in quantity:
		var clone := source.duplicate() as MeshInstance3D
		target.get_parent().add_child(clone)   # <- see note below
		var mat: StandardMaterial3D = clone.get_active_material(0)
		if mat == null:
			mat = StandardMaterial3D.new()
			mat.albedo_color = Color.WHITE
		elif mat is BaseMaterial3D:
			mat = mat.duplicate()
		else:
			mat = null
		if mat is BaseMaterial3D:
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

func kick(target :Player=null, direction := Vector3(), force := 70.0, unattach := true, speed := 1.0) -> void:
	var subject :Ball= target.grab_ball_area.ball
	var aim_dir := (target.transform.basis * direction).normalized()
	var final_direction := -aim_dir * force
	var ball_traj := PackedVector3Array()
	var ball_traj_range := 380.0
	var ball_traj_inbetween := 5.0
	
	ball_traj = subject.predict_trajectory(subject.global_position, final_direction, ball_traj_range/60.0, 1/60.0, speed)
	
	for i in ball_traj.size() / ball_traj_inbetween:
		var clone := target.ball_aim.duplicate()
		get_tree().current_scene.add_child(clone)
		clone.global_position = ball_traj[i * ball_traj_inbetween]
		clone.scale *= 0.2
		delete(clone, 0.025)
	
	target.ball_aim.global_position = ball_traj[ball_traj.size() - 1]
	
	if unattach:
		subject.current_owner = null
		subject.last_owner = target
		subject.apply_impulse(final_direction)
		subject = null
		target.grab_ball_area.ball = null

func delete(target:Node3D, seconds := 0.5):
	await get_tree().create_timer(seconds).timeout
	target.queue_free()
