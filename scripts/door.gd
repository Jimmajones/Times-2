extends Area2D


# This method should be connected to its corresponding key, likewise for
# the "_on_Key_close_door" method
func _on_Key_open_door():
	# Turn off visibility and collision.
	hide()
	$CollisionShape2D.set_deferred("disabled", true)


func _on_Key_close_door():
	# Turn on visibility and collision.
	show()
	$CollisionShape2D.set_deferred("disabled", false)
