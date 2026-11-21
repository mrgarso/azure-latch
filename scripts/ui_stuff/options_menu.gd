extends PauseMenu


func make_visible(target_to_show : Control, target_to_hide : Control = null) -> void:
	if target_to_show == null:
		print("abort changes")
		return
	target_to_show.visible = true
	if target_to_hide == null: return
	target_to_hide.visible = false


func _on_button_pressed() -> void:
	make_visible(get_parent(), self)
