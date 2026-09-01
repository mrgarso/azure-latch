extends Node
class_name command

func effect(target:Player=null) -> String:
	if target == null:
		return "yo, there aint no one to pass the ball to, ye dumbahh"
	else:
		print(get_tree().current_scene.get_children())
		return "oke"
