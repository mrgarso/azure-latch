extends Resource
class_name SkillBuilderBlock

# Override this in every block. `parent` is the player using the skill,
# `target` is the player being affected (if any).
func run(parent : Player = null, target : Player = null) -> void:
	push_warning("run() not implemented in " + str(get_script().get_global_name()))
