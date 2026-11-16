extends Node3D
class_name Model

@export var skeleton_3d: Skeleton3D
@export var body: MeshInstance3D
@export var animation_player: AnimationPlayer
@export var ball_holder: Node3D

func set_modulate(mod : Color, transparent := true) -> void:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = mod
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA if transparent \
	else BaseMaterial3D.TRANSPARENCY_DISABLED
	body.set_surface_override_material(0, mat)
	body.set_surface_override_material(1, mat)
