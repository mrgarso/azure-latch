extends CanvasLayer
class_name Ui

@export var score_local_team: Label
@export var time: Label
@export var score_other_team: Label
var local_team := ""
var other_team := ""

func update_labels_time(secs := 0) -> void:
	@warning_ignore("integer_division")
	var minutes := secs / 60
	var seconds := secs % 60
	
	time.text = "%02d:%02d" % [minutes, seconds]
