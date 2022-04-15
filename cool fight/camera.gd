extends KinematicBody2D

onready var player = get_parent().get_node("player")
onready var cam = $camera

var speed = 200
var direction = Vector2()
var velocity = Vector2()

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()
	if abs(player.position.x - position.x) >= 100:
		direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	else:
		direction = Vector2()
	velocity = direction * speed
	move_and_slide(velocity)
