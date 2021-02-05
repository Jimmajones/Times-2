extends Node

var has_swivelled : bool = false

# This is a specific "tutorial scene" for the first level, triggered
# if this is the player's first time. Shows various prompts with controls.

func _on_Player_intro_finished():
	if Save.player_is_noob:
		$LblSwivel.show()

func _input(event: InputEvent):
	if Save.player_is_noob and !has_swivelled and (event.is_action_pressed("up") or event.is_action_pressed("down")):
		$LblMove.show()
		has_swivelled = true

func _on_TutorialArea_area_entered(_area: Area2D):
	if Save.player_is_noob:
		$LblSwivel.hide()
		$LblMove.hide()
		$LblCheckpoint.show()


func _on_FirstCheckpoint_area_entered(_area: Area2D):
	if Save.player_is_noob:
		$LblCheckpoint.hide()
		$LblGoodbye.show()
		yield(get_tree().create_timer(3.0), "timeout")
		$LblGoodbye.hide()
