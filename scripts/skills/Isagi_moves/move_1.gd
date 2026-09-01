extends Node
class_name move

func use(target:Player=null, speed:=1.0, godmode:=false, vulnerable:=false):
	if target.can_move:
		target.using_move = true
		SB.screen_flash(target, Color(1,0,1,0.1), 0.5)
		SB.velocity(target, Vector2(0,-5), 0.3, 0.7)
		SB.afterimage(target, 6, 0.05, 0.4, Color(0.6,0,0.6, 0.5))
		await SB.wait(2, speed)
		var dir := Input.get_axis("a","d")
		if dir >= 0:
			SB.velocity(target, Vector2(10,-5), 0.3, 0.7)
			await SB.wait(2, speed)
			SB.velocity(target, Vector2(5,0), 0.3, 0.7)
		else:
			SB.velocity(target, Vector2(-10,-5), 0.3, 0.7)
			await SB.wait(2, speed)
			SB.velocity(target, Vector2(-5,0), 0.3, 0.7)
		await SB.wait(20, speed)
		target.using_move = false
