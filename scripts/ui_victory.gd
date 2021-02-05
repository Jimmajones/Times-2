extends NinePatchRect


var rng = RandomNumberGenerator.new()

# Some super COOL and ABSTRACT random prompts for the player on level completion.
var messages = [
	"GOOD JOB",
	"EXCELLENT WORK",
	"HIP 2 B^2",
	"ALL IN ALL...",
	"WHAT'D'JA LEAVE BEHIND FOR ME?",
	"IT IS CAST: THE 4-SIDED DIE",
	"BONJOUR, ETRANGER",
	"THIS WAS NEVER GOING TO BE EASY",
	"WHAT FOUR?",
]

signal victory_open
signal victory_close
signal go_to_menu
signal go_to_next
signal restart

func _init():
	rng.randomize()

func open(turns_made : int):
	emit_signal("victory_open")
	$LblFlavor.text = messages[rng.randi_range(0, messages.size() - 1)]
	$LblTurnsCount.text = String(turns_made)
	$BtnNext.grab_focus()
	show()

func close():
	emit_signal("victory_close")
	hide()

func _on_World_goal_reached(turns):
	open(turns)

func _on_BtnMenu_pressed():
	emit_signal("go_to_menu")
	close()

func _on_BtnNext_pressed():
	emit_signal("go_to_next")
	close()

func _on_BtnRestart_pressed():
	emit_signal("restart")
	close()
