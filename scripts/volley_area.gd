extends Area3D

var ball : Ball = null

func _on_body_entered(body: Node3D) -> void:
	if body is Ball:
		print("ballin ", body)
