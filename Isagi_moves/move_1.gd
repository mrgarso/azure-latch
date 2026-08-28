extends Node

func use(target:Player=null, speed:=1.0, godmode:=false, vulnerable:=false):
	target.using_move = true
	if godmode:
		target.iframes = true
	if vulnerable:
		target.iframes = false
	velocity(target, Vector2(-5,-3), .35, 0.15)
	screen_flash(target, Color(0.0,0.3,1,0.2), 0.2)
	afterimage(target, 1, 0.1, )
	fov_change(target, 70, 90, 0.1)
	await wait(5, speed)
	fov_change(target, 90, 75, 0.5)
	await wait(20, speed)
	velocity(target, Vector2(7,-3), .35, 0.15)
	afterimage(target, 1, 0.1, )
	fov_change(target, 70, 90, 0.1)
	screen_flash(target, Color(0.0,0.3,1,0.2), 0.2)
	await wait(5, speed)
	fov_change(target, 90, 80, 0.5)
	await wait(30, speed)
	screen_flash(target, Color(0.7,0.3,0.3,0.3), 0.5)
	velocity(target, Vector2(0,-20), .75, 0.75)
	afterimage(target, 6, 0.04, 1.0, Color(0,0,1,0.25))
	fov_change(target, 70, 120, 0)
	await wait(2, speed)
	fov_change(target, 120, 75, 0.6)
	target.using_move = false

func velocity(target:Player=null, direction:=Vector2(0,0), duration := 1.0, decay := 0.99):
	@warning_ignore("shadowed_variable")
	var velocity := direction
	for i in (Engine.physics_ticks_per_second * duration):
		target.direction = velocity
		velocity *= decay
		await get_tree().create_timer(Engine.time_scale/Engine.physics_ticks_per_second).timeout

func wait(frames := 60, speed:= 1.0):
	for i in frames:
		await get_tree().create_timer(Engine.time_scale/Engine.physics_ticks_per_second * speed).timeout

func afterimage(target :Player= null, quantity := 5, in_between := 0.1, duration := 1.0, custom_color := Color(1,1,1,1)):
	var source :MeshInstance3D= target.get_node("MeshInstance3D")
	for i in quantity:
		var clone := source.duplicate() as MeshInstance3D
		get_parent().add_child(clone)
		var mat :StandardMaterial3D= clone.get_active_material(0)
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
		clone.name = "afterimage %d" % i
		clone.top_level = true
		var tween := clone.create_tween()
		tween.tween_property(clone, "transparency", 1.0, duration)
		tween.tween_callback(clone.queue_free)
		await get_tree().create_timer(in_between).timeout

func fov_change(target :Player= null, from := 70, to := 70, duration := 1.0):
	var camera :Camera3D= target.get_node("shoulder").get_node("SpringArm3D").get_node("Camera3D")
	camera.fov = from
	var tween = create_tween()
	tween.tween_property(camera,"fov",to,duration)

func screen_flash(target :Player= null, color :=Color(1,1,1,1), duration := 1.0):
	var screen :CanvasLayer= target.get_node("screen_effects")
	for i in screen.get_child_count():
		var subject :Control= screen.get_child(i)
		if subject is TextureRect:
			subject.self_modulate = color
			var tween = create_tween()
			tween.tween_property(subject,"self_modulate",Color(color.r,color.g,color.b,0),duration)
