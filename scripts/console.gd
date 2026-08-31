extends VBoxContainer

@export var console_logger: PanelContainer
@export var console_typer: LineEdit
@export var player: Player

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("console"):
		show_console()

func show_console() -> void:
	if !self.visible:
		self.visible = true
		player.can_move = false
		console_typer.edit()
	else:
		self.visible = false
		player.can_move = true
		console_typer.unedit()
