extends Node2D

var BULLET_SCENE = preload("res://scripts/pistol_bullet.gd")


func fire(speed : float):
	var bullet_inst : Node2D = BULLET_SCENE.instance()
	bullet_inst.position = $Muzzle.global_position
	bullet_inst.rotation = global_rotation
	bullet_inst.bullet_speed = speed
	get_owner().get_owner().add_child(bullet_inst)
