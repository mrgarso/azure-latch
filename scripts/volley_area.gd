extends Area3D

var ball : Ball = null

func _on_area_entered(area: Node3D) -> void:
	var target :Node3D= area.get_parent()
	if target is Ball:
		print("vollin ", target)
		ball = target


func _on_area_exited(area: Node3D) -> void:
	var target :Node3D= area.get_parent()
	if target is Ball:
		print("vollin n't ", target)
		ball = null
