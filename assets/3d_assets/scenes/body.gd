extends Node3D
class_name body

@export var skeleton_3d: Skeleton3D
@export var Body: MeshInstance3D
@export var animation_player: AnimationPlayer

func set_modulate(mod : Color, transparent := true) -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = mod
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA if transparent \
	else BaseMaterial3D.TRANSPARENCY_DISABLED
	Body.set_surface_override_material(0, mat)
	Body.set_surface_override_material(1, mat)
