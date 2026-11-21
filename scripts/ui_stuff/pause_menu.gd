extends PanelContainer
class_name PauseMenu

@export var player : Player
var main_menu_focused := true

func _on_continue_pressed() -> void:
	player.pause(true)

func _on_options_pressed() -> void:
	make_visible(null)

func _on_continue_3_pressed() -> void:
	get_tree().quit()

func make_visible(target_to_show : Control, target_to_hide : Control = null) -> void:
	if target_to_show != null:
		target_to_show.visible = true
	if target_to_hide != null:
		target_to_hide.visible = false
