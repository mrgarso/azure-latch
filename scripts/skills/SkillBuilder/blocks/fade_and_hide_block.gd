class_name FadeAndHideBlock
extends SkillBuilderBlock

@export var mesh_path : NodePath
@export var duration := 0.5

func run(parent : Player = null, target : Player = null) -> void:
	var mesh := parent.get_node_or_null(mesh_path) as MeshInstance3D
	if mesh == null:
		push_warning("FadeAndHideBlock: no MeshInstance3D at " + str(mesh_path))
		return
	SB.fade_and_hide(mesh, duration)
