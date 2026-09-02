extends MeshInstance3D
class_name trajectory_line


#NO USAR, ES PURO MRD ESTO, gratzie :3
func update_trajectory(points: PackedVector3Array) -> void:
	if points.size() < 2:
		mesh = null
		return
	
	var arr_mesh := ArrayMesh.new()
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = points
	
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINE_STRIP, arrays)
	mesh = arr_mesh
