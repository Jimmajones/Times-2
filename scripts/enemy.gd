extends Area2D

const ANGLE : float = PI / 16		# A multiple of pi for rounding
const ANIM_PROPORTION : float = 0.25		# How long turning should take as a proportion of firing rate (x2)

export (float) var offset : float = 0.0
export (float) var fire_rate : float = 1.0
export (float) var rotation_per_shot : float = 0
export (float) var bullet_speed : float = 400.0
export (int) var reverse_after : int = 0

var shots_fired : int = 0
var rotation_delay = fire_rate * ANIM_PROPORTION
var anim_time = fire_rate * ANIM_PROPORTION

onready var offset_timer : Timer = get_node("OffsetTimer")
onready var fire_timer : Timer = get_node("FireTimer")
onready var rotate_timer : Timer = get_node("RotationTimer")


# Call to begin the timers for firing and turning
func start_firing():
	if offset:
		offset_timer.start(offset)
	else:
		fire_timer.start(fire_rate)

# Stop firing and turning
func stop_firing():
	fire_timer.stop()

func shoot():
	# Increment shot counter and begin turning (with delay)
	shots_fired += 1
	$Pistol.fire(bullet_speed)
	$AnimationPlayer.play("fire")
	rotate_timer.start(rotation_delay)

func _on_OffsetTimer_timeout():
	shoot()
	fire_timer.start(fire_rate)

func _on_FireTimer_timeout():
	shoot()

func _on_RotationTimer_timeout():
	if reverse_after and (shots_fired == reverse_after):
		rotation_per_shot = -rotation_per_shot
		shots_fired = 0
	$Tween.interpolate_property(self, "rotation",
			rotation, stepify(rotation + deg2rad(rotation_per_shot), ANGLE),
			anim_time, Tween.TRANS_SINE)
	$Tween.start()
