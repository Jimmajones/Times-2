extends Area2D

const FULL_ANGLE : float = PI
const RIGHT_ANGLE : float = (PI / 2)
const MOVE_TIME : float = 0.1
const RESPAWN_TIME : float = 1.0
const RESPAWN_SPINS : int = 4
const PITCH_UP : float = 0.1
const DRAG_THRESH : float = 35.0

var intro_finished : bool = false
var checkpoint_count : int = 0
var turns_made : int = 0
var respawn_point : Vector2

onready var tween : Tween = get_node("Tween")
onready var swivel : Node2D = get_node("Swivel")
onready var ray_clockwise : RayCast2D = get_node("RayClockwise")
onready var ray_anticlockwise : RayCast2D = get_node("RayAnticlockwise")

signal intro_finished
signal respawning
signal checkpoint_reached(count)
signal goal_reached(turns)


func _ready():
	respawn_point = global_position
	$AnimationPlayer.play("intro")

func _unhandled_input(event: InputEvent):
	if !tween.is_active() and intro_finished:
		var input_right : bool = event.is_action_pressed("right")
		var input_left : bool = event.is_action_pressed("left")
		var input_down : bool = event.is_action_pressed("down")
		var input_up : bool = event.is_action_pressed("up")
		var input_mod : bool = event.is_action_pressed("modifier")

		# Basic touch input. Kind of sucks - on-screen controller
		# would probably be better.
		if event is InputEventScreenDrag:
			if event.relative.x > DRAG_THRESH:
				input_right = true
			elif event.relative.x < -DRAG_THRESH:
				input_left = true
			elif event.relative.y > DRAG_THRESH:
				input_down = true
			elif event.relative.y < -DRAG_THRESH:
				input_up = true

		var rotation_amount : float

		# Swivel movement
		if input_down or input_up or input_mod:
			if input_down:
				rotation_amount = RIGHT_ANGLE
				$Audio/ClockSwivel.play()
			elif input_up:
				rotation_amount = -RIGHT_ANGLE
				$Audio/AntiSwivel.play()
			elif input_mod:
				rotation_amount = FULL_ANGLE
				$Audio/FullSwivel.play()
			# Move the swivel and update raycasts to be accurate
			tween_swivel(swivel.position.rotated(rotation_amount), MOVE_TIME)
			ray_clockwise.rotation += rotation_amount
			ray_anticlockwise.rotation += rotation_amount

		# "Actual" movement
		elif input_right or input_left:
			update_raycasts()
			if input_right and !ray_clockwise.is_colliding():
				turns_made += 1
				rotation_amount = RIGHT_ANGLE
				$Audio/ClockMove.play()
			elif input_left and !ray_anticlockwise.is_colliding():
				turns_made += 1
				rotation_amount = -RIGHT_ANGLE
				$Audio/AntiMove.play()
			else:
				rotation_amount = 0
				$AnimationPlayer.play("blocked")
			# Move around the swivel in the desired direction, if not blocked.
			if rotation_amount:
				tween_movement(pos_rotate_around_point(swivel.global_position, rotation_amount),
						rotation + rotation_amount, MOVE_TIME)

func _on_Player_area_entered(area: Area2D):
	if area.is_in_group("bullets"):
		respawn()
		area.queue_free()
	elif area.is_in_group("goals"):
		finish()
		area.queue_free()
	elif area.is_in_group("checkpoints"):
		checkpoint(area.position)
		area.queue_free()

func _on_Tween_tween_all_completed():
	$CollisionShape2D.set_deferred("disabled", false)

func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name == "intro":
		emit_signal("intro_finished")
		intro_finished = true

func respawn():
	emit_signal("respawning")
	$CollisionShape2D.set_deferred("disabled", true)
	tween_movement(respawn_point, stepify(rotation, RIGHT_ANGLE) + FULL_ANGLE * RESPAWN_SPINS, RESPAWN_TIME)
	$Audio/Respawn.play()

func checkpoint(new_point):
	emit_signal("checkpoint_reached", checkpoint_count)
	respawn_point = new_point
	checkpoint_count += 1
	$Audio/Checkpoint.play()
	$Audio/Checkpoint.pitch_scale += PITCH_UP

func finish():
	emit_signal("goal_reached", turns_made)
	$Audio/Goal.play()

func pos_rotate_around_point(point : Vector2, angle : float) -> Vector2:
	return point + (position - point).rotated(angle)

func update_raycasts():
	ray_clockwise.force_raycast_update()
	ray_anticlockwise.force_raycast_update()

func tween_swivel(to_point : Vector2, time : float):
# warning-ignore:return_value_discarded
	tween.interpolate_property(swivel, "position",
			swivel.position, to_point,
			time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
# warning-ignore:return_value_discarded
	tween.start()

func tween_movement(to_point : Vector2, to_rotation : float, time : float):
# warning-ignore:return_value_discarded
	tween.interpolate_property(self, "global_position",
			global_position, to_point,
			time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
# warning-ignore:return_value_discarded
	tween.interpolate_property(self, "rotation",
			rotation, to_rotation,
			time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
# warning-ignore:return_value_discarded
	tween.start()
