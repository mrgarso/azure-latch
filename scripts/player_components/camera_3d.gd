extends Camera3D

@export var sens := 0.001
@export var initial_spring_distance := 10.0
@export var spring_arm_3d: SpringArm3D
@export var shoulder: Node3D
@export var player: Player
var desired_fov := 75.0
var fov_changers :Array[float] = []
var mouse_mode := Input.mouse_mode
var mouse_motion := Vector2()

func _physics_process(delta: float) -> void:
	if fov_changers:
		pass
	if Input.is_action_just_pressed("shift"):
		if player.mode != "player": return
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _ready() -> void:
	current = (player.mode == "player")
	spring_arm_3d.spring_length = initial_spring_distance

func invert_shift_lock():
	if player.mode != "player": return
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_motion = event.relative
		spring_arm_3d.rotation.x -= (event.relative.y * sens) * (int(player.mode == "player"))
		player.rotation.y -= (event.relative.x * sens) * (int(player.mode == "player"))
