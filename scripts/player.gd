extends CharacterBody3D
class_name Player

@export_enum("player", "dummy") var mode := "player"
@export var dummy_behaviours :Array[DummyBehaviours]= []
@export var team := ""
@export var speed := 20.0
@export var speed_on_ball := 13.5
@export var accel := 10.0
@export var frict := 10.0
@export var jump_speed := 35.0
@export var gravity := 40.0
@export var ball_holder: Node3D
@export var spring_arm_3d: SpringArm3D
@export var grab_ball_area: Area3D
@export var fps_label: Label
@export var moves: Movement

var dummy_behaving := false
var ball :Ball= null:
	set(value):
		grab_ball_area.ball = value
		ball = value
		if value != null:
			current_speed = speed_on_ball
			ball.current_owner = self
		else:
			current_speed = speed
var can_grab_ball := true:
	set(value):
		grab_ball_area.can_grab = value
		can_grab_ball = value
var can_move := true:
	set(value):
		can_move = value
		direction = Vector2.ZERO
var current_gravity := 0.0
var current_speed := 0.0
var using_move := false
var iframes := false
var true_iframes := false
var dribbling := false:
	set(value):
		print(value)
		dribbling = value
var direction := Vector2.ZERO
var forw := Vector3.ZERO
var sides := Vector3.ZERO
var up := Vector3.ZERO
var movement := Vector3.ZERO
var impulses: Array[Impulse] = []

func _ready() -> void:
	current_gravity = gravity
	current_speed = speed

func _physics_process(delta: float) -> void:
	if !dummy_behaving and mode == "dummy":
		dummy_behaving = true
		for i in dummy_behaviours:
			i.run(self)
	fps_label.text = "fps = " + str(Engine.get_frames_per_second())
	forw = transform.basis.z
	sides = transform.basis.x
	up = transform.basis.y
	
	var impulse_sum := Vector3.ZERO
	var override_impulse_sum := Vector3.ZERO
	for imp in impulses.filter(func(i): return !i.override):
		impulse_sum += imp.vec
	for imp in impulses.filter(func(i): return i.override):
		override_impulse_sum += imp.vec
	
	if using_move:
		direction = Vector2(impulse_sum.x, impulse_sum.z)
	elif can_move:
		direction = (Input.get_vector("a", "d", "w", "s") * int(mode == "player")) + (Vector2(override_impulse_sum.x, override_impulse_sum.z))
		if is_on_floor() and Input.is_action_pressed("space"):
			velocity.y = (jump_speed) * int(mode == "player")
	
	movement = ((direction.x * sides) + (direction.y * forw)) * current_speed
	if direction:
		velocity.x = lerp(velocity.x, movement.x, delta * accel)
		velocity.z = lerp(velocity.z, movement.z, delta * accel)
	else:
		velocity.x = lerp(velocity.x, 0.0, delta * frict)
		velocity.z = lerp(velocity.z, 0.0, delta * frict)
	if impulse_sum.y or using_move:
		velocity.y = lerp(velocity.y, impulse_sum.y * current_speed, delta * accel)
	if override_impulse_sum.y:
		velocity.y = lerp(velocity.y, override_impulse_sum.y * current_speed, delta * accel)
	if not is_on_floor():
		velocity.y -= current_gravity * delta * 4
	move_and_slide()

func tackle(reset_pos := false, tack := false, side := "none") -> void:
	await moves.tackle_and_dash(reset_pos, tack, side)

func tackled(perpetrator : Player = null, ragdoll := 80.0) -> void:
	if dribbling:
		if perpetrator: SB.velocity(self, true, global_position.direction_to(perpetrator.global_position) * 0.1, 0.5, 0.92, 40.0, true) 
		SB.screen_flash(self)
		return
	SB.fov_change(self, 120, 90, 0.1)
	if perpetrator: perpetrator.ball = ball
	ball = null
	if perpetrator: SB.velocity(self, true, global_position.direction_to(perpetrator.global_position) * ragdoll, 0.5, 0.92, 40.0, true) 
	else:SB.velocity(self, true, Vector3(0,0,ragdoll), 0.5, 0.92, 40.0, true)
	SB.fov_change(self, 90, 70, 0.2)
	await SB.wait(1)
