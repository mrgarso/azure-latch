extends Node

func use(target:Player=null, speed:=1.0, godmode:=false, vulnerable:=false):
	if godmode:
		target.iframes = true
	if vulnerable:
		target.iframes = false
	velocity(target, Vector2(-5,-3), .35, 0.15)
	afterimage(target, 1)
	await wait(30, speed)
	velocity(target, Vector2(7,-3), .35, 0.15)
	afterimage(target, 1)
	await wait(30, speed)
	velocity(target, Vector2(0,-20), .75, 0.75)
	afterimage(target, 5)

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

func afterimage(target :Player= null, quantity := 5, in_between := 0.1, duration := 1.0, trans := 0.5):
	var source :MeshInstance3D= target.get_node("MeshInstance3D")
	for i in quantity:
		var clone := source.duplicate() as MeshInstance3D
		get_parent().add_child(clone)
		#var mat := (source.get_surface_override_material(0) if source.get_surface_override_material(0) else source.mesh.surface_get_material(0)).duplicate() as StandardMaterial3D
		clone.transparency = trans
		clone.global_position = target.global_position
		clone.name = "afterimage" + str(i)
		clone.top_level = true
		await get_tree().create_timer(in_between).timeout
		get_tree().create_timer(duration).timeout.connect(clone.queue_free)
