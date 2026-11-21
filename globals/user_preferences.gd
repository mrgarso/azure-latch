extends Node
class_name UserPreferences

const SAVE_PATH := "user://preferences.cfg"

var sens := 0.001
var sens_scale := 1.0
var ui_scale := 1.0
var master_volume := 1.0
var sound_volume := 1.0
var music_volume := 1.0

func _ready():
	load_preferences()

func save_preferences():
	var config := ConfigFile.new()
	config.set_value("controls", "sens", sens)
	config.set_value("controls", "sens_scale", sens_scale)
	config.set_value("display", "ui_scale", ui_scale)
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "sound_volume", sound_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.save(SAVE_PATH)

func load_preferences():
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	
	sens = config.get_value("controls", "sens", sens)
	sens_scale = config.get_value("controls", "sens_scale", sens_scale)
	ui_scale = config.get_value("display", "ui_scale", ui_scale)
	master_volume = config.get_value("audio", "master_volume", master_volume)
	sound_volume = config.get_value("audio", "sound_volume", sound_volume)
	music_volume = config.get_value("audio", "music_volume", music_volume)
