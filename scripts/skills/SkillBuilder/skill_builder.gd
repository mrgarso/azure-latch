extends Node
class_name SkillBuilder

var players_positions : Dictionary[Player, Vector3]

func velocity(target: Player,fade_out := false, direction := Vector3.ZERO, \
duration := 1.0, decay := 0.99, custom_gravity :float= target.gravity, override := false, reset_y := false) -> void:
	var imp := Impulse.new()
	var changed_gravity := custom_gravity != target.gravity
	if changed_gravity:
		target.current_gravity = custom_gravity
	if reset_y:
		target.velocity.y = 0.0
	imp.vec = direction
	imp.override = override
	target.impulses.append(imp)
	if fade_out:
		for i in (Engine.physics_ticks_per_second * duration):
			imp.vec *= decay
			if imp.cleared:
				break
			await wait(1)
	else:
		for i in (Engine.physics_ticks_per_second * duration):
			if imp.cleared:
				break
			await wait(1)
	target.impulses.erase(imp)
	if changed_gravity and is_equal_approx(target.current_gravity, custom_gravity):
		target.current_gravity = target.gravity

func clear_velocities(target : Player) -> void:
	var impulses := target.impulses
	for i in impulses:
		i.cleared = true

func tackle(target : Player, tack := true, reset_pos := false, side := "none") -> void:
	if target.ball == null: await target.tackle(reset_pos, tack, side)

func wait(frames := 60, speed := 1.0) -> void:
	for i in frames:
		await get_tree().create_timer(Engine.time_scale / Engine.physics_ticks_per_second * speed).timeout

func afterimage(target: Player, quantity := 5, in_between := 0.1,
		duration := 1.0, custom_color := Color(1, 1, 1, 1), offset := Vector3.ZERO) -> void:
	#var skel := target.model.skeleton_3d as Skeleton3D
	var body_mesh := target.model.body as MeshInstance3D
	
	var holder := Node3D.new()
	holder.name = "afterimages of %s" % target.name
	get_tree().current_scene.add_child(holder)
	
	var materials: Array[StandardMaterial3D] = []
	for i in quantity:
		if not is_instance_valid(body_mesh) or holder == null:
			print(is_instance_valid(body_mesh), " ", holder == null)
			break
		var mat := StandardMaterial3D.new()
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.albedo_color = custom_color
		
		var img := MeshInstance3D.new()
		img.mesh = body_mesh.bake_mesh_from_current_skeleton_pose()
		img.material_override = mat
		holder.add_child(img)
		img.global_transform = body_mesh.global_transform
		img.global_position += offset
		materials.append(mat)
		
		await get_tree().create_timer(in_between).timeout
	if holder == null: return
	var tween := create_tween().set_parallel(true)
	for mat in materials:
		tween.tween_property(mat, "albedo_color:a", 0.0, duration)
	await tween.finished
	if holder == null: return
	holder.queue_free()

func clear_afterimages(target) -> void:
	var multi :Node3D= get_tree().current_scene.get_node(str("afterimages of ", target.name))
	if multi == null:
		return
	multi.queue_free()

enum Interp { CONST, LINEAR, SINE_IN, SINE_OUT, SINE_IN_OUT, EXPO_IN, EXPO_OUT, EXPO_IN_OUT }

func apply_interp(kind: Interp, t: float) -> float:
	match kind:
		Interp.CONST:       return 1.0 if t >= 1.0 else 0.0
		Interp.LINEAR:      return t
		Interp.SINE_IN:     return 1.0 - cos(t * PI / 2.0)
		Interp.SINE_OUT:    return sin(t * PI / 2.0)
		Interp.SINE_IN_OUT: return -(cos(PI * t) - 1.0) / 2.0
		Interp.EXPO_IN:     return 0.0 if t <= 0.0 else pow(2.0, 10.0 * t - 10.0)
		Interp.EXPO_OUT:    return 1.0 if t >= 1.0 else 1.0 - pow(2.0, -10.0 * t)
		Interp.EXPO_IN_OUT:
			if t <= 0.0: return 0.0
			if t >= 1.0: return 1.0
			if t < 0.5:  return pow(2.0, 20.0 * t - 10.0) / 2.0
			return (2.0 - pow(2.0, -20.0 * t + 10.0)) / 2.0
	return t

func fov_change(target: Player, from := 70.0, to := 70.0, duration := 1.0, kind := Interp.LINEAR) -> void:
	var camera: Camera3D = target.get_node("shoulder/SpringArm3D/Camera3D")
	if camera.has_meta("fov_tween"):
		var old: Tween = camera.get_meta("fov_tween")
		if old and old.is_valid():
			old.kill()
	camera.fov = from
	var tween := create_tween()
	camera.set_meta("fov_tween", tween)
	tween.tween_method(
		func(t: float): camera.fov = lerpf(from, to, apply_interp(kind, t)),
		0.0, 1.0, duration
	)

func save_position(target : Player = null, pos := Vector3(), id := "") -> void:
	players_positions

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

var stored_final_direction := Vector3.INF
var stored_curvature_dir := Vector3.INF
var stored_time_for_curve := -1.0
var stored_curvature_force := -1.0
var stored_ball_pos := Vector3.INF
var last_pred_msec := 0 
func kick(target: Player = null, direction := Vector3(), force := 70.0, \
unattach := true, speed := 1.0, show_traj := false, \
curvature_dir := Vector3.ZERO,  time_for_curve := 0.0, curvature_force := 0.0) -> void:
	var subject: Ball = target.ball
	var aim_dir := (target.transform.basis * direction).normalized()
	var final_direction := -aim_dir * force
	subject.velocity = Vector3.ZERO
	if show_traj:
		var changed := final_direction.distance_to(stored_final_direction) > 0.005 \
			or curvature_dir.distance_to(stored_curvature_dir) > 0.005 \
			or subject.global_position.distance_to(stored_ball_pos) > 0.25 \
			or time_for_curve != stored_time_for_curve \
			or curvature_force != stored_curvature_force
		
		var now := Time.get_ticks_msec()
		var due := unattach or (now - last_pred_msec) >= 50
		
		#print("dir %s, curv_dir %s, time_curv %s, curv_force %s, changed %s" % [
		#final_direction != stored_final_direction,
		#curvature_dir != stored_curvature_dir,
		#time_for_curve != stored_time_for_curve,
		#curvature_force != stored_curvature_force,
		#changed
		#])
		
		if changed and due:
			last_pred_msec = now
			stored_ball_pos = subject.global_position
			
			stored_final_direction = final_direction
			stored_curvature_dir = curvature_dir
			stored_time_for_curve = time_for_curve
			stored_curvature_force = curvature_force
			var ball_traj := subject.predict_trajectory(final_direction, \
				240 / float(Engine.physics_ticks_per_second), \
				1.0 / Engine.physics_ticks_per_second, speed, \
				curvature_dir, time_for_curve, curvature_force)
			
			var traj_ball_traj := PackedVector3Array()
			for i in range(0, ball_traj.size(), 2):
				traj_ball_traj.append(ball_traj[i])
			subject.trajectory_mesh.mesh = subject.build_traj_mesh(traj_ball_traj, \
				0.15, 3, Color(0, 0.25, 0, 1), 1)
		show(subject.trajectory_mesh)
	else:
		subject.trajectory_mesh.visible = false
	
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

var hitbox_detailed_list := {
		"collided":null,
		"velocity":Vector3.ZERO,
		"position":Vector3.ZERO,
		"class": &""
		}

func hitbox(parent: Player = null, size := Vector3.ONE * 10, offset := Vector3.ZERO, \
duration := 1.0, target := HitboxTargets.BALL, include_ball_holder := false, \
include_not_ball_holder := true, include_teammates := false, include_enemies := true) -> void:
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
		if target == HitboxTargets.BALL and parent.ball != null: break
		area.global_position = parent.global_position
		collision.disabled = !parent.can_grab_ball
		if area.get_overlapping_areas() and area.get_overlapping_areas()[0].get_parent() != parent:
			collided = true
			target_hit = area.get_overlapping_areas()[0].get_parent()
			break
		await wait(1)
	delete(area, 0.0)
	if target_hit is Ball:
		parent.ball = target_hit

func hitbox_detailed(parent: Player = null, size := Vector3.ONE * 10, offset := Vector3.ZERO, \
duration := 1.0, target := HitboxTargets.BALL, include_ball_holder := false, \
include_not_ball_holder := true, include_teammates := false, include_enemies := true) -> Dictionary:
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
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = collision.shape
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = area.collision_mask
	for i in Engine.physics_ticks_per_second * duration:
		if target == HitboxTargets.BALL and parent.ball != null: break
		area.global_position = parent.global_position
		collision.disabled = !parent.can_grab_ball
		query.transform = area.global_transform
		var space_state: PhysicsDirectSpaceState3D = parent.get_world_3d().direct_space_state
		var intersections := space_state.intersect_shape(query)
		if not intersections.is_empty():
			for t in space_state.intersect_shape(query):
				var other := (t.collider as Node3D).get_parent() as Player
				if _is_valid_target(other, parent, include_ball_holder,
						include_not_ball_holder, include_teammates, include_enemies):
					target_hit = other
					break
			if target_hit: break
			await wait(1)
	delete(area, 0.0)
	if target_hit is Ball:
		parent.ball = target_hit
	if target_hit == null:
		return hitbox_detailed_list
	return {
		"collided":target_hit,
		"velocity":target_hit.velocity,
		"position":target_hit.global_position,
		"class":target_hit.get_script().get_global_name()
		}

func _is_valid_target(target: Player, parent: Player, include_ball_holder: bool,
		include_not_ball_holder: bool, include_teammates: bool, include_enemies: bool) -> bool:
	if target == null or target == parent:
		return false
	
	var has_ball := target.ball != null
	if has_ball and not include_ball_holder: return false
	if not has_ball and not include_not_ball_holder: return false
	
	var is_teammate :bool= target.team == parent.team
	if is_teammate and not include_teammates: return false
	if not is_teammate and not include_enemies: return false

	return true

func player_state(target : Player = null, grab_ball := true, iframes := false, duration := 1.0) -> void:
	var before := {
		"grab": target.can_grab_ball,
		}
	target.can_grab_ball = grab_ball
	await wait(duration * 60)
	target.can_grab_ball = before.grab
