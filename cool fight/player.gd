extends KinematicBody2D

var health : int = 5
var shieldhealth : float = 3

onready var box = $shield
onready var hurt = $box
onready var weapon = $dangerous
onready var hitsound = $hit
onready var blocksound = $block
onready var deathsound = $die

var speed = 200
var direction = Vector2()
var velocity = Vector2()

var attacking = false
var blocking = false
var invincible = false

onready var sprite = $AnimatedSprite
onready var healthbar = $health
onready var defensebar = $defend

onready var camera = get_parent().get_node("camera")

func _ready():
	healthbar.max_value = health
	defensebar.max_value = shieldhealth * 1000

func _input(event):
	if event is InputEventMouseMotion:
		if event.position.x + camera.position.x - 600 > position.x:
			box.position.x = 18
			hurt.position.x = -18
			weapon.position.x = 40
			sprite.flip_h = false
		elif event.position.x + camera.position.x - 600 < position.x:
			box.position.x = -18
			hurt.position.x = 18
			weapon.position.x = -40
			sprite.flip_h = true

func _process(delta):
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	if Input.is_action_just_pressed("attack") and !attacking and !blocking:
		_attack()
	if Input.is_action_pressed("block") and !attacking and !blocking and shieldhealth > 0:
		#_block()
		blocking = true
		sprite.play("block")
	if (Input.is_action_just_released("block") or shieldhealth <= 0) and blocking:
		blocking = false
		sprite.play("default")
	if health <= 0:
		invincible = true
		rotation_degrees += 1
		scale.x *= 0.99
		scale.y *= 0.99
		direction = Vector2()
	velocity = direction * speed
	velocity.y /= 2
	move_and_slide(velocity)
	if health < 5:
		healthbar.visible = true
	else:
		healthbar.visible = false
	if shieldhealth * 1000 < defensebar.max_value - 5:
		defensebar.visible = true
		if !(Input.is_action_pressed("block")):
			shieldhealth += 0.005
	else:
		defensebar.visible = false
	healthbar.value = health
	defensebar.value = shieldhealth * 1000
	#box.disabled = blocking
	weapon.active.disabled = !attacking

func _attack():
	var t = Timer.new()
	t.set_one_shot(true)
	add_child(t)
	attacking = true
	sprite.play("attack")
	t.start(0.2)
	yield(t, "timeout")
	t.queue_free()
	attacking = false
	sprite.play("default")

func _invincibility():
	var i = Timer.new()
	i.set_one_shot(true)
	add_child(i)
	invincible = true
	sprite.modulate = Color(0.5, 0.5, 0.5)
	i.start(0.5)
	yield(i, "timeout")
	i.queue_free()
	invincible = false
	sprite.modulate = Color(1, 1, 1)

func hit(damage : int):
	if !invincible:
		if !blocking:
			health -= damage
			if health <= 0:
				deathsound.play()
			else:
				hitsound.play()
		else:
			shieldhealth -= 1
			blocksound.play()
		_invincibility()

#func _on_hitbox_hit():
	#if !blocking:
	#	health -= hitbox.damage
	#	hitbox.damage = 0
