extends Node2D
class_name LevelClass

# Generic class for the root of level scenes - handles fancy color-phasing,
# music, starting/stopping enemies

export (float) var BULLET_LIGHTNESS
export (float) var FLOOR_DARKNESS
export (float) var SPEED_PER_CHECKPOINT

export (Color) var color_1 : Color
export (Color) var color_2 : Color
export (Color) var checkpoint_blend : Color

var started : bool = false
var goal_reached : bool = false
var speed : float = 0
var x : float = 5
var interpolation : float
var new_color : Color

onready var music = get_node("Music")

signal goal_reached(turns)

func _process(delta : float):
	# Cyclic function for colouring the world.
	interpolation = 0.5 * sin(x) + 0.5
	new_color = color_1.linear_interpolate(color_2, interpolation)

	x += delta * speed
	if goal_reached and interpolation <= 0.01:
		speed = 0

	for node in get_tree().get_nodes_in_group("world"):
		# Make some objects lighter or darker, or blend with a different
		# (self-specified) colour entirely.
		if node.is_in_group("bullets"):
			node.modulate = new_color.lightened(BULLET_LIGHTNESS)
		elif node.is_in_group("floor"):
			node.modulate = new_color.darkened(FLOOR_DARKNESS)
		elif node.is_in_group("checkpoints"):
			node.modulate = new_color.blend(checkpoint_blend)
		else:
			node.modulate = new_color

func _on_Player_checkpoint_reached(count):
	# Play a new music track and increase "colour-phasing" speed.
	if !started:
		for node in get_tree().get_nodes_in_group("enemies"):
			node.start_firing()
		started = true

	speed += SPEED_PER_CHECKPOINT
	if music.get_child(count):
		music.get_child(count).play(music.get_child(0).get_playback_position())

func _on_Player_goal_reached(turns):
	emit_signal("goal_reached", turns)
	goal_reached = true
	for child in music.get_children():
		child.stop()
	for node in get_tree().get_nodes_in_group("enemies"):
		node.stop_firing()
