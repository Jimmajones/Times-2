extends Area2D

signal open_door
signal close_door


func _on_Key_area_entered(_area: Area2D):
	emit_signal("open_door")
	hide()
	$CollisionShape2D.set_deferred("disabled", true)
	$AudioCollect.play()

func _on_Player_respawning():
	emit_signal("close_door")
	show()
	$CollisionShape2D.set_deferred("disabled", false)
