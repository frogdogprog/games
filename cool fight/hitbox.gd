extends Area2D

class_name hitbox

signal hit

export var damage : int

func hit(d : int):
	damage = d
	emit_signal("hit")
