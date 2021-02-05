extends VBoxContainer

const LEVELS : int = 5

var lvl_button_scene = preload("res://scenes/ui/ui_lvl_btn.tscn")
var level_names = [
	"Clocking Out",
	"Apprehension",
	"Tight Budget",
	"All Turned Around",
	"True Blue",
]
var is_open : bool
var is_website : bool = false
var is_touch : bool = false

signal level_selected(level_num)


func _ready():
	is_website = (OS.get_name() == "HTML5")
	is_touch = OS.has_touchscreen_ui_hint()
	# Game just crashes if the user uses this button on web platform.
	if is_website:
		$HBoxContainer/BtnQuit.hide()

	for i in range(LEVELS):
		var btn_inst = lvl_button_scene.instance()
		btn_inst.get_node("BtnLevel").connect("pressed", self, "_button_pressed", [i])
		btn_inst.get_node("LblTitle").text = level_names[i]
		$LevelGrid/GridContainer.add_child(btn_inst)

	open()

func _button_pressed(num):
	close_to_game(num)

func open():
	is_open = true
	$LevelGrid/GridContainer.get_child(0).get_node("BtnLevel").grab_focus()
	$Music.play()
	for i in range(LEVELS):
		if Save.level_unlocked < i:
			$LevelGrid/GridContainer.get_child(i).get_node("BtnLevel").disabled = true
		else:
			$LevelGrid/GridContainer.get_child(i).get_node("BtnLevel").disabled = false
		if Save.scores[i]:
			$LevelGrid/GridContainer.get_child(i).get_node("LblScore").text = "Turns: " + String(Save.scores[i])
	show()

func close_to_game(level_num : int):
	is_open = false
	emit_signal("level_selected", level_num)
	$Music.stop()
	hide()

func _on_Victory_go_to_menu():
	open()

func _on_Settings_go_to_menu():
	open()

func _on_Settings_close_settings():
	if is_open:
		$HBoxContainer/BtnSettings.grab_focus()

func _on_BtnQuit_pressed():
	get_tree().quit()
