extends Area3D

var ball : Ball = null

func _physics_process(delta: float) -> void:
	if !ball:
		if Input.is_action_pressed("m1") and Input.is_action_pressed("m2"):
			pass

func _on_area_entered(area: Node3D) -> void:
	var target :Node3D= area.get_parent()
	if target is Ball:
		ball = target


func _on_area_exited(area: Node3D) -> void:
	var target :Node3D= area.get_parent()
	if target is Ball:
		ball = null
