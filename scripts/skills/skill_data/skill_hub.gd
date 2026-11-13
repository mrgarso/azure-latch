@tool
extends Control
class_name SkillHub

@export var h_box_container: HBoxContainer
@export var skills : Array[Skill] = []:
	set(value):
		for i in skills:
			if i and i.modified.is_connected(skill_changed):
				i.modified.disconnect(skill_changed)
		skills = value
		for i in skills:
			if i and not i.modified.is_connected(skill_changed):
				i.modified.connect(skill_changed)
		if is_node_ready():
			reload()

const SKILL_BUTTON := preload("res://assets/3d_assets/scenes/skill_button.tscn")

func skill_changed() -> void:
	if not is_inside_tree():
		return
	reload.call_deferred()

func reload(force := false) -> void:
	if !Engine.is_editor_hint() and !force:
		return
	for i in h_box_container.get_children():
		h_box_container.remove_child(i)
		i.queue_free()
	var root := get_tree().edited_scene_root
	for i in skills:
		if i == null:
			continue
		var inst := SKILL_BUTTON.instantiate() as SkillButton
		inst.name = i.skill_name if !i.skill_name.is_empty() else '-'
		inst.skill_name = i.skill_name if !i.skill_name.is_empty() else '-'
		inst.key_bind = i.key_bind
		inst.top_text_string = i.top_text
		inst.bottom_text_string = i.bottom_text
		h_box_container.add_child(inst)
		if Engine.is_editor_hint():
			inst.owner = root

func _ready() -> void:
	reload(true)

func _process(delta: float) -> void:
	if !Engine.is_editor_hint():
		check_input()

func check_input() -> void:
	for i in skills:
		if Input.is_action_just_pressed(i.key_bind):
			print("SE PRINTIO EN ", i.key_bind, " POR ", i.skill_name)
