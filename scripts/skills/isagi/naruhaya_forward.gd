extends Move


@warning_ignore("unused_parameter")
static func use(target:Player=null, speed:=1.0, godmode:=false, vulnerable:=false):
	target.using_move = true
	SB.fov_change(target, 75, 60, 0.35)
	await SB.wait(20)
	target.using_move = false
	SB.fov_change(target, 100, 75, 0.2)
	SB.velocity(target, false, Vector3(0,0,-5), 0.25, 0.85, 40.0, true, true)
