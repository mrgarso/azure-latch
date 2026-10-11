class_name ShowBlock
extends SkillBuilderBlock

## Path to the MeshInstance3D, relative to the player using the skill.
@export var mesh_path : NodePath

func run(parent : Player = null, target : Player = null) -> void:
	var mesh := parent.get_node_or_null(mesh_path) as MeshInstance3D
	if mesh == null:
		push_warning("ShowBlock: no MeshInstance3D at " + str(mesh_path))
		return
	SB.show(mesh)
