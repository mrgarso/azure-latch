extends Control

@export var name_id: LineEdit
@export var Port: LineEdit
@export var Ip: LineEdit
@export var play: Button
@export var options: Button
@export var quit: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	Online.name_id = name_id.text
	var port := int(Port.text)
	if Ip.text.is_empty():
		Online.host(port)
	else:
		Online.join(Ip.text, port)
	get_tree().change_scene_to_file("res://scenes/map.tscn")


func _on_options_pressed() -> void:
	print("todavia no hay nada manolo")


func _on_quit_pressed() -> void:
	get_tree().quit()
