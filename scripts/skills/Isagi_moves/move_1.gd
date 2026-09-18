extends Node
class_name move

func use(target:Player=null, speed:=1.0, godmode:=false, vulnerable:=false):
	if target.can_move:
		target.using_move = true
		var hitbox :Dictionary= {
		"collided": false,
		"target_hit": null
	}
		SB.afterimage(target, 5, 0.15)
		SB.velocity(target, false, Vector3(0, 1.2, -1.2), 0.3, 1, 0.0)
		while hitbox["collided"] == false:
			hitbox = await SB.hitbox(target, Vector3.ONE * 10, Vector3.ZERO, 0.3, SB.HitboxTargets.BALL)
			if target.impulses.is_empty():
				break
		if hitbox["collided"]:
			SB.clear_velocities(target)
			target.grab_ball_area.ball = hitbox["target_hit"]
			await SB.velocity(target, false, Vector3(0, .9, 0), 0.2, 1, 0.0)
		target.using_move = false
