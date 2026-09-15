extends Node
class_name move

func use(target:Player=null, speed:=1.0, godmode:=false, vulnerable:=false):
	if target.can_move:
		target.using_move = true
		SB.velocity(target, Vector3(0, 3.5, -3.5), 0.1, 1)
		await SB.wait(20, speed)
		target.using_move = false
