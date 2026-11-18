@tool
extends Control
class_name SkillButton

@export var skill_text: Label
@export var top_text: Label
@export var bind_text: Label
@export var bottom_text: Label
@export var color_rect: ColorRect
@export var skill_container: PanelContainer

@export var background_color_available := Color(0.07,0.07,0.07, 0.57)
@export var background_color_cooldown := Color(0.7, 0.1, 0.1, 0.57)

var current_background_color : Color:
	set(value):
		var target := skill_container.get_theme_stylebox("panel") as StyleBoxFlat
		target.bg_color = value
	get():
		var target := skill_container.get_theme_stylebox("panel") as StyleBoxFlat
		return target.bg_color

var skill_name_default_value := "Control"
@export var skill_name: String:
	set(value):
		skill_name = value
		if value != "":
			skill_text.text = value
		else:
			skill_text.text = skill_name_default_value

var bind_text_default_value := "1"
@export var key_bind: String:
	set(value):
		key_bind = value
		if value != "":
			bind_text.text = value
		else:
			bind_text.text = bind_text_default_value

var top_text_default_value := ""
@export var top_text_string: String:
	set(value):
		top_text_string = value
		if cooldown_progress > 0.0:
			return
		if value != "":
			top_text.text = value
		else:
			top_text.text = top_text_default_value

var bottom_text_default_value := ""
@export var bottom_text_string: String:
	set(value):
		bottom_text_string = value
		if value != "":
			bottom_text.text = value
		else:
			bottom_text.text = bottom_text_default_value

@export var cooldown := 1.0
@export var cooldown_color := Color(0.70,0.35,0.35, 0.75)
var cooldown_progress := 0.0:
	set(value):
		cooldown_progress = value
		if value > 0.0:
			current_background_color = background_color_cooldown
			on_cooldown = true
			top_text.text = str(cooldown_progress, 's')
		else:
			current_background_color = background_color_available
			on_cooldown = false
var on_cooldown := false

func _physics_process(delta: float) -> void:
	cooldown_progress -= delta * (int(on_cooldown) * int(cooldown_progress > 0.0))
