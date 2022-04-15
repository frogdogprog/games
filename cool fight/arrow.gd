extends Node2D

class_name arrow

var speed = 250

func _ready():
	_die()

func _physics_process(delta):
	position += transform.x * speed * delta

func _die():
	var l = Timer.new()
	l.set_one_shot(true)
	add_child(l)
	l.start(5)
	yield(l, "timeout")
	l.queue_free()
	queue_free()

func _on_dangerous_hit():
	queue_free()
