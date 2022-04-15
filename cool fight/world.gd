extends Node2D

var rng = RandomNumberGenerator.new()
var f = preload("res://fight.tscn")

func _input(event):
	if Input.is_action_just_pressed("spawn"):
		var n = f.instance()
		if n != null:
			n.set_global_position(Vector2(rng.randi_range(0, 1200), rng.randi_range(25, 575)))
