extends Node
class_name move

func use(target:Player=null, speed:=1.0, godmode:=false, vulnerable:=false):
	if target.can_move:
		target.using_move = true
		SB.screen_flash(target, Color(1,0,1,0.1), 0.5)
		await SB.wait(5, speed)
		target.using_move = false
