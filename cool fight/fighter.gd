extends KinematicBody2D

class_name fight

var health : int = 4
var shieldhealth : float = 1

#onready var box = $hitbox
onready var weapon = $dangerous

var speed = 150
var direction = Vector2()
var velocity = Vector2()

var attacking = false
var blocking = false
var invincible = false

var target
var distance
var action = "idle"
var changingaction = true
var decidingtoattack = true

onready var sprite = $AnimatedSprite
onready var healthbar = $health

#onready var xform = transform.basis_xform()
#onready var shape = $CollisionShape2D
#onready var shapexform = $CollisionShape2D.transform.basis_xform()

func _process(delta):
	target = get_parent().get_node("player")
	distance = sqrt(pow(target.position.x - position.x, 2) + pow(target.position.y - position.y, 2))
	if abs(target.position.x - position.x) <= 800:
		if changingaction:
			_changeaction()
	else:
		action = "idle"
	if action == "attack":
		if distance > 40:
			if target.position.x > position.x:
				direction.x = 1
			elif target.position.x < position.x:
				direction.x = -1
			if target.position.y > position.y:
				direction.y = 1
			elif target.position.y < position.y:
				direction.y = -1
		else:
			direction = Vector2()
		if decidingtoattack:
			_decidetoattack()
		if target.position.x > position.x:
			weapon.position.x = 40
			sprite.flip_h = false
		if target.position.x < position.x:
			weapon.position.x = -40
			sprite.flip_h = true
	if action == "defend":
		direction = Vector2()
		blocking = true
		sprite.play("block")
		if target.position.x > position.x:
			weapon.position.x = 40
			sprite.flip_h = false
		if target.position.x < position.x:
			weapon.position.x = -40
			sprite.flip_h = true
	else:
		if blocking:
			blocking == false
		if sprite.animation == "block":
			sprite.play("default")
	if action == "avoid":
		if distance < 400:
			if target.position.x < position.x:
				direction.x = 1
			elif target.position.x > position.x:
				direction.x = -1
			if target.position.y < 301:
				direction.y = 1
			elif target.position.y > 300:
				direction.y = -1
			if direction.x > 0:
				weapon.position.x = 40
				sprite.flip_h = false
			if direction.x < 0:
				weapon.position.x = -40
				sprite.flip_h = true
		else:
			direction = Vector2()
			if target.position.x > position.x:
				weapon.position.x = 40
				sprite.flip_h = false
			if target.position.x < position.x:
				weapon.position.x = -40
				sprite.flip_h = true
	velocity = direction * speed
	velocity.y /= 2
	move_and_slide(velocity)
	if health < 4:
		healthbar.visible = true
	else:
		healthbar.visible = false
	healthbar.value = health
	weapon.active.disabled = !attacking
	if health <= 0:
		queue_free()

func _changeaction():
	var c = Timer.new()
	c.set_one_shot(true)
	add_child(c)
	changingaction = false
	var a = randi() % 7
	if a < 3:
		action = "attack"
	if a > 2 and a < 5 and shieldhealth > 0:
		action = "defend"
	else:
		if a < 4:
			action = "attack"
		elif a > 3:
			action = "avoid"
	if a > 4:
		action = "avoid"
	c.start(rand_range(1, 3))
	yield(c, "timeout")
	c.queue_free()
	changingaction = true

func _decidetoattack():
	var a = Timer.new()
	a.set_one_shot(true)
	add_child(a)
	decidingtoattack = false
	_attack()
	a.start(rand_range(0.3, 2.2))
	yield(a, "timeout")
	a.queue_free()
	decidingtoattack = true

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

func _block():
	blocking = true
	sprite.play("block")

func _unblock():
	blocking = false
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
		else:
			shieldhealth -= 1
		_invincibility()
