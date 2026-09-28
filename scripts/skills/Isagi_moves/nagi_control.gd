extends Node
class_name move

func use(target:Player=null, speed:=1.0, godmode:=false, vulnerable:=false):
	if target.can_move:
		target.using_move = true
		
		if target.is_on_floor():
			SB.clear_velocities(target)
			SB.fov_change(target, 60, 70, 0.8)
			var first_dash_velocity := -5.6
			var first_dash_duration := 0.6
			SB.velocity(target, true, Vector3(0, 0, first_dash_velocity), first_dash_duration, 0.97)
			await SB.hitbox(target, Vector3.ONE * 5, Vector3.ZERO, first_dash_duration, SB.HitboxTargets.BALL)
			if target.ball != null:
				SB.player_state(target, false, false, 0.5)
				SB.fov_change(target, 75, 70, 0.1)
				SB.clear_velocities(target)
				SB.kick(target, Vector3(0,1,1), -first_dash_velocity * 7.0, true, 2.0, true)
				SB.velocity(target, true, Vector3(0, 0, -2.6), first_dash_duration, 0.97)
				await SB.hitbox(target, Vector3.ONE * 5, Vector3.ZERO, first_dash_duration, SB.HitboxTargets.BALL)
			target.using_move = false
			return
		
		SB.afterimage(target, 5, 0.15, 0.3, Color(0,0.3,0.7,0.4))
		SB.velocity(target, true, Vector3(0, 2.4, -1.2), 0.6, .97, 0.0)
		await SB.hitbox(target, Vector3.ONE * 5, Vector3.ZERO, 0.6, SB.HitboxTargets.BALL)
		if target.ball:
			SB.fov_change(target, 70, 50, 0.05)
			SB.clear_afterimages(target)
			SB.clear_velocities(target)
			SB.fov_change(target, 50, 70, 0.3)
			await SB.velocity(target, false, Vector3(0, .9, 0), 0.3, 1, 0.0)
		target.using_move = false
