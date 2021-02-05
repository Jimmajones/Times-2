extends Node

export (AudioStreamSample) var loop_1
export (AudioStreamSample) var loop_2
export (AudioStreamSample) var loop_3

func _ready():
	$Loop1.stream = loop_1
	$Loop2.stream = loop_2
	$Loop3.stream = loop_3
