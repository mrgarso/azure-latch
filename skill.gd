@tool
extends Control
class_name SkillButton

signal modified()

@export var skill_text: Label
@export var top_text: Label
@export var bottom_text: Label
@export var color_rect: ColorRect

var skill_name_default_value := "Control"
@export var skill_name: String:
	set(value):
		modified.emit()
		skill_name = value
		if value != "":
			skill_text.text = value
		else:
			skill_text.text = skill_name_default_value

var top_text_default_value := "off-ball"
@export var top_text_string: String:
	set(value):
		modified.emit()
		top_text_string = value
		if cooldown_progress > 0.0:
			return
		if value != "":
			top_text.text = value
		else:
			top_text.text = top_text_default_value

var bottom_text_default_value := "trap"
@export var bottom_text_string: String:
	set(value):
		modified.emit()
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
			on_cooldown = true
			top_text.text = str(cooldown_progress, 's')
		else:
			on_cooldown = false
var on_cooldown := false

func _physics_process(delta: float) -> void:
	cooldown_progress -= delta * (int(on_cooldown) * int(cooldown_progress > 0.0))

func _process(delta: float) -> void:
	pass
