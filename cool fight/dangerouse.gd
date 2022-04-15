extends Area2D

class_name dangerous

var damage : int = 1

onready var active = $CollisionShape2D

signal hit

func _process(delta):
	for t in get_overlapping_areas():
		if t is hitbox:
			t.hit(damage)
	for u in get_overlapping_bodies():
		if u is KinematicBody2D and u != get_parent() and !((u is fight or u is ranged) and (get_parent() is fight or get_parent() is arrow)) :
			u.hit(damage)
			emit_signal("hit")
