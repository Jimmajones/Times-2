extends Node

const LEVELS : int = 100
const SAVE_PATH = "user://times_save.save"

var player_is_noob : bool = false
var level_unlocked : int
var scores : Array

func _init():
	var f = File.new()
	# Determine if the player is new by checking if they've opened the game
	# before. Kind of sloppy (the player could open and close the game
	# without playing the first level).
	if !f.file_exists(SAVE_PATH):
		player_is_noob = true
		create_save()
	load_save()

# Save file consists entirely of 16-bit integers - one storing the
# current level the player has unlocked (for convenience), the next 100 storing
# the score for each level.
func create_save():
	var new_save = File.new()
	new_save.open(SAVE_PATH, File.WRITE)
	new_save.store_16(0)
	for _i in range(LEVELS):
		new_save.store_16(0)
	new_save.close()

func save():
	var new_save = File.new()
	new_save.open(SAVE_PATH, File.WRITE)
	new_save.store_16(level_unlocked)
	for i in range(LEVELS):
		new_save.store_16(scores[i])
	new_save.close()

func load_save():
	var save_file = File.new()
	save_file.open(SAVE_PATH, File.READ)
	level_unlocked = save_file.get_16()
	for _i in range(LEVELS):
		scores.append(save_file.get_16())
	save_file.close()

func update_level(level : int):
	var save_file = File.new()
	save_file.open(SAVE_PATH, File.READ_WRITE)
	level_unlocked = level
	save_file.store_16(level_unlocked)
	save_file.close()

func update_score(level : int, new_score : int):
	var save_file = File.new()
	save_file.open(SAVE_PATH, File.READ_WRITE)
	scores[level] = new_score
	for _i in range(level + 1):
		save_file.get_16()
	save_file.store_16(new_score)
	save_file.close()

func get_score(level : int):
	var score : int
	var save_file = File.new()
	save_file.open(SAVE_PATH, File.READ)
	for _i in range(level + 1):
		save_file.get_16()
	score = save_file.get_16()
	save_file.close()
	return score
