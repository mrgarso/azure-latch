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
@export var background_color_unavailable := Color(0.24,0.24,0.24, 0.8)
@export var background_color_cooldown := Color(0.7, 0.1, 0.1, 0.57)

var _shown_progress := 0.0

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
var cooldown_progress := 0.0:
	set(value):
		cooldown_progress = maxf(value, 0.0)
		_update_fill()
		var shown := snappedf(cooldown_progress, 0.1)
		if is_equal_approx(shown, _shown_progress):
			return
		_shown_progress = shown
		top_text.text = "%.1fs" % shown if shown > 0.0 else top_text_string

func _ready() -> void:
	color_rect.color = background_color_cooldown
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.resized.connect(_update_pivot)
	_update_pivot()
	_update_fill()
	var sb := skill_container.get_theme_stylebox("panel").duplicate()
	skill_container.add_theme_stylebox_override("panel", sb)

func _update_pivot() -> void:
	color_rect.pivot_offset = Vector2(0.0, color_rect.size.y)

func _update_fill() -> void:
	var ratio := clampf(cooldown_progress / maxf(cooldown, 0.001), 0.0, 1.0)
	color_rect.visible = ratio > 0.0
	color_rect.scale.y = maxf(ratio, 0.001)
