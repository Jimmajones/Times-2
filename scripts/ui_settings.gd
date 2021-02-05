extends NinePatchRect

const SETTINGS_PATH : String = "user://settings.cfg"
const DEFAULT_MUSIC : float = 0.8
const DEFAULT_EFFECTS : float = 0.8
const DEFAULT_FULLSCREEN : bool = false
const DEFAULT_BORDERLESS : bool = false

var config : ConfigFile = ConfigFile.new()
var is_open : bool = false
var in_game : bool = false
var in_victory : bool = false

signal close_settings
signal go_to_menu


# For some reason I was possessed to handle settings here as opposed to in
# the global save file. It's completely for our purpouses though.

func _init():
	# Create a default config file if it does not exist.
	if config.load(SETTINGS_PATH):
		if !config.has_section_key("audio", "music"):
			config.set_value("audio", "music", DEFAULT_MUSIC)
		if !config.has_section_key("audio", "effects"):
			config.set_value("audio", "effects", DEFAULT_EFFECTS)
		if !config.has_section_key("display", "fullscreen"):
			config.set_value("display", "fullscreen", DEFAULT_FULLSCREEN)
		if !config.has_section_key("display", "borderless"):
			config.set_value("display", "borderless", DEFAULT_BORDERLESS)
		safe_save(config)

func _ready():
	enact_settings()

func _input(event):
	if event.is_action_pressed("pause") and !in_victory:
		if is_open:
			close()
		else:
			open()
	elif event.is_action_pressed("ui_cancel") and is_open:
		close()

func open():
	is_open = true
	get_tree().paused = true

	$BtnExit.grab_focus()
	if in_game:
		$BtnMenu.show()
	else:
		$BtnMenu.hide()
	# Visually keep settings up-to-date.
	$VBoxContainer/CheckFullscreen.pressed = config.get_value("display", "fullscreen")
	$VBoxContainer/CheckBorder.pressed = config.get_value("display", "borderless")
	$VBoxContainer/HBoxMusic/HSliderMusic.value = config.get_value("audio", "music")
	$VBoxContainer/HBoxEffects/HSliderEffects.value = config.get_value("audio", "effects")
	show()

func close():
	emit_signal("close_settings")
	is_open = false
	get_tree().paused = false

	enact_settings()
	safe_save(config)

	hide()

func enact_settings():
	OS.window_fullscreen = config.get_value("display", "fullscreen")
	OS.window_borderless = config.get_value("display", "borderless")
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(config.get_value("audio", "music")))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), linear2db(config.get_value("audio", "effects")))

func safe_save(config_file : ConfigFile):
	if config_file.save(SETTINGS_PATH):
		print("Error saving config file.")

func _on_CheckFullscreen_toggled(button_pressed: bool):
	config.set_value("display", "fullscreen", button_pressed)
	enact_settings()

func _on_CheckBorder_toggled(button_pressed: bool):
	config.set_value("display", "borderless", button_pressed)
	enact_settings()

func _on_HSliderMusic_value_changed(value: float):
	config.set_value("audio", "music", value)
	enact_settings()

func _on_HSliderEffects_value_changed(value: float):
	config.set_value("audio", "effects", value)
	enact_settings()

func _on_BtnExit_pressed():
	close()

func _on_BtnMenu_pressed():
	emit_signal("go_to_menu")
	close()

func _on_BtnSettings_pressed():
	open()

func _on_LevelSelect_level_selected(_level_num):
	in_game = true

func _on_Victory_go_to_menu():
	in_game = false

func _on_Victory_victory_open():
	in_victory = true

func _on_Victory_victory_close():
	in_victory = false

func _on_World_loading_level():
	in_game = true

func _on_World_leaving_level():
	in_game = false
