extends VBoxContainer

@export var console_logger: PanelContainer
@export var console_typer: LineEdit
@export var player: Player
@export var suggestion_box: PanelContainer
@export var suggestion_text: Label
@export var text_handler: VBoxContainer
var commands :Array[StringName] = ["ball", "kick", "quit", "help", "controls"]

func _ready() -> void:
	suggestion_text.anchor_top = 1.0
	suggestion_text.anchor_bottom = 1.0
	suggestion_text.grow_vertical = Control.GROW_DIRECTION_BEGIN

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("console"):
		show_console()
	

func show_console() -> void:
	if !self.visible:
		console_typer.clear()
		self.visible = true
		player.can_move = false
		console_typer.grab_focus()
		console_typer.edit()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		console_typer.clear()
		self.visible = false
		player.can_move = true
		console_typer.unedit()
		#if mouse_mode == Input.MOUSE_MODE_CAPTURED:
			#Input.mouse_mode = mouse_mode

func check(text := "") -> void:
	if text.is_empty():
		suggestion_box.visible = false
		return
	else:
		suggestion_text.text = ("\n".join(get_autocomplete(text)))
		suggestion_box.size = Vector2(suggestion_box.size.x,0)
		suggestion_box.global_position = get_suggestion_position()
		suggestion_box.visible = true

func get_autocomplete(text := "") -> Array[String]:
	var suggestions :Array[String]= [""]
	if !text.is_empty():
		for i in commands:
			if i.begins_with(text):
				suggestions.append(i)
		suggestions.erase("")
		if suggestions.is_empty():
			suggestions.append("no commands found")
		return suggestions
	else:
		return suggestions

func get_suggestion_position() -> Vector2:
	var font := console_typer.get_theme_font("font")
	var font_size := console_typer.get_theme_font_size("font_size")
	var text_width := font.get_string_size(
		console_typer.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size
	).x
	#var margin_left := console_typer.get_theme_stylebox("normal").content_margin_left

	var x_offset := text_width
	print(Vector2(max(x_offset, 165), -suggestion_box.size.y/2))
	return console_typer.global_position + Vector2(max(x_offset, 170), -suggestion_box.size.y/1.75)

func _on_console_typer_text_changed(new_text: String) -> void:
	check(new_text)


func _on_console_typer_text_submitted(new_text: String) -> void:
	console_typer.clear()
	var command_received := str(get_autocomplete(new_text)[0])
	var command_label := Label.new()
	command_label.text = command_received
	text_handler.add_child(command_label)
	if text_handler.get_child_count() > 15:
		text_handler.get_child(0).queue_free()
