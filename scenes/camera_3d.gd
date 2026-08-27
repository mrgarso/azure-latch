extends Camera3D

@export var initial_fov := 90.0
@export var sens := 0.001
@export var initial_spring_distance := 10.0
@export var spring_arm_3d: SpringArm3D
@export var shoulder: Node3D
@export var player: Player

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	spring_arm_3d.spring_length = initial_spring_distance
	fov = initial_fov

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		spring_arm_3d.rotation.x -= event.relative.y * sens
		player.rotation.y -= event.relative.x * sens
