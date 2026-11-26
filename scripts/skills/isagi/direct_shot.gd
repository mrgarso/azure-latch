extends Move


@warning_ignore("unused_parameter")
static func use(target:Player=null, speed:=1.0, godmode:=false, vulnerable:=false):
	SB.fov_change(target, 75, 70, 0.35, SkillBuilder.Interp.EXPO_IN)
	await SB.wait(35)
	SB.fov_change(target, 80, 75, 1.0, SkillBuilder.Interp.EXPO_OUT)
	if target.ball != null:
		SB.play_audio("res://audio/gunshot_only.wav")
		SB.kick(target, Vector3(0,0.1,1), 90, true, 1.7, false, Vector3(), \
		0.0, 0.0, true, -2.0, 0.0)
	else:
		var x := await SB.hitbox_detailed(target, Vector3(10,10,10), \
		Vector3(), 0.3, SB.HitboxTargets.BALL)
		if x.collided == null: return
		if x.collided is Ball and x.collided != null:
			target.ball = x.collided
			SB.play_audio("res://audio/gunshot_only.wav")
			SB.kick(target, Vector3(0,0.1,1), 90, true, 1.7, false, Vector3(), \
			0.0, 0.0, true, -2.0, 0.0)
