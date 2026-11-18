extends Move


@warning_ignore("unused_parameter")
static func use(target:Player=null, speed:=1.0, godmode:=false, vulnerable:=false):
	SB.fov_change(target, 75, 55, 0.5, SkillBuilder.Interp.EXPO_IN)
	await SB.wait(40)
	SB.kick(target, Vector3(0,0.1,1), 90, true, 1.7, true, Vector3(), \
	0.0, 0.0, true, -2.0, 0.0)
	SB.fov_change(target, 95, 75, 0.5, SkillBuilder.Interp.EXPO_OUT)
