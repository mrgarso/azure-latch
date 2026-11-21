extends Field


@warning_ignore("unused_parameter")
func goal(goaler : Player, amount : int, reset := false, \
reset_time := 1.0) -> void:
	#print(goaler, " MADE %s GOALLLLL, " %[amount])
	if !reset:return
	await get_tree().create_timer(reset_time).timeout
	for i in children:
		if i.has_method("goal_behaviour"): i.goal_behaviour()
