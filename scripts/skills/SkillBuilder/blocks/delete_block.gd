class_name DeleteBlock
extends SkillBuilderBlock

## Path to the Node3D to delete, relative to the player using the skill.
@export var target_path : NodePath
@export var seconds := 0.5
## If off, the next block runs right away and the node is deleted later.
@export var wait_until_done := false

func run(parent : Player = null, target : Player = null) -> void:
	var node := parent.get_node_or_null(target_path) as Node3D
	if node == null:
		push_warning("DeleteBlock: no Node3D at " + str(target_path))
		return
	if wait_until_done:
		await SB.delete(node, seconds)
	else:
		SB.delete(node, seconds)
