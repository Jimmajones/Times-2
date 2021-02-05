extends Area2D

var bullet_speed : float = 400.0
var velocity : Vector2


func _enter_tree():
	velocity = Vector2(bullet_speed, 0).rotated(rotation)

func _physics_process(delta : float):
	position += velocity * delta

func _on_Bullet_area_entered(_area: Area2D):
	queue_free()

func _on_Bullet_body_entered(_body: Node):
	queue_free()
