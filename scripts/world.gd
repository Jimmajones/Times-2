extends Node2D

const LEVEL_PATH : String = "res://scenes/levels/"

var curr_level : int = 0

var levels = [
	preload("res://scenes/levels/lvl1.tscn"),
	preload("res://scenes/levels/lvl2.tscn"),
	preload("res://scenes/levels/lvl3.tscn"),
	preload("res://scenes/levels/lvl4.tscn"),
	preload("res://scenes/levels/lvl5.tscn"),
]

signal loading_level
signal leaving_level
signal goal_reached

func load_level(level_num):
	if level_num < levels.size():
		curr_level = level_num
		clean_out()
		emit_signal("loading_level")

		var level_inst = levels[level_num].instance()
		call_deferred("add_child", level_inst)
		level_inst.connect("goal_reached", self, "_goal_reached")

func next_level():
	curr_level += 1
	load_level(curr_level)

func clean_out():
	emit_signal("leaving_level")
	for child in get_children():
		child.queue_free()

func _goal_reached(turns):
	emit_signal("goal_reached", turns)
	if (curr_level + 1) >= Save.level_unlocked:
		Save.update_level(curr_level + 1)
	if !Save.scores[curr_level] or turns < Save.scores[curr_level]:
		Save.update_score(curr_level, turns)

func _on_LevelSelect_level_selected(level_num):
	load_level(level_num)

func _on_Victory_go_to_next():
	next_level()

func _on_Victory_restart():
	load_level(curr_level)

func _on_Victory_go_to_menu():
	clean_out()

func _on_Settings_go_to_menu():
	clean_out()
