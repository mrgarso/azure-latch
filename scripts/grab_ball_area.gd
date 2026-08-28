extends Area3D

var ball : Ball = null
@export var kick_strength := 5.0
@export var ball_holder: Node3D
@export var player: Player

func _physics_process(delta: float) -> void:
	if ball:
		ball.global_position = ball_holder.global_position
		if Input.is_action_just_pressed("m1"):
			ball = null

func _on_area_entered(area: Node3D) -> void:
	var target :Node3D= area.get_parent()
	if target is Ball:
		print("ballin ", target)
		ball = target


func _on_area_exited(area: Node3D) -> void:
	var target :Node3D= area.get_parent()
	if target is Ball:
		print("ballin n't ", target)
		ball = null
