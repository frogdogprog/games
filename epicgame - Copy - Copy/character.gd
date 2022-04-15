extends KinematicBody

signal landed

var direction = Vector3()
var velocity = Vector3()
var speed = 6
var acceleration = .5
var gravity = 20
var jump = 10
var donaldduck = Vector3()

onready var look = $look

var jumping = false
var snapdirection = Vector3.DOWN
var snaplength = 1

var skating = false
onready var board = $skatboard
onready var shape = $CollisionShape
var s : Shape
var b : Shape
var boarding = false
var jumped = false
var origin : Vector3
var airtime = 0

var trick = [0, "nothing"]
var grinding = false
var nogrind = 0
var moving = true
var checkpoint = 0
var point = Vector3(0, 0, 0)

onready var sprite = $character
onready var boar = $skatboard/CSGMesh

func _ready():
	skating = false
	jumping = false
	s = shape.shape
	b = board.shape
	board.disabled = true
	origin = shape.transform.origin
	airtime = 0
	$look/phone.set_current(true)

func _input(event):
	if event is InputEventMouseMotion and Input.is_action_pressed("pan"):
		look.rotate_y(deg2rad(-event.relative.x * .2))
	if Input.is_action_just_pressed("skate") and ((is_on_floor() and !skating) 
	or (($down.global_transform.origin.y - $down.get_collision_point().y < .5 
	and skating))) and moving:
		skating = !skating
		if skating:
			transform.origin.y += 1
			speed = 1
		else:
			speed = 6
		shape.set_disabled(skating)
		board.set_disabled(!skating)
		boar.set_visible(skating)
	if Input.is_action_pressed("brake") and skating:
		acceleration = 5
	if Input.is_action_just_released("brake"):
		acceleration = .5
		speed = 1

func _process(delta):
	if Input.is_action_pressed("left"):
		look.rotate_y(deg2rad(.5))
	elif Input.is_action_pressed("right"):
		look.rotate_y(deg2rad(-.5))
	if is_on_floor():
		checkpoint += 1
		if checkpoint > 500:
			point = global_transform.origin
			checkpoint = 0
	if Input.is_action_pressed("phone"):
		$look/phone.current = true
	else:
		$look/phone.current = false
	if Input.is_action_just_pressed("reset"):
		global_transform.origin = point + Vector3(0, 2, 0)
		global_transform = align(global_transform, global_transform.basis.y - Vector3.DOWN)
	direction = Vector3()
	var y = $down.global_transform.origin.y - $down.get_collision_point().y
	if y > 1.2:
		$down.set_cast_to(to_local(Vector3.DOWN))
	else:
		$down.set_cast_to(Vector3(0, -2, 0))
	if nogrind > 0:
		nogrind -= 1
	if Input.is_action_pressed("jump") and !grinding:
		if is_on_floor() and !skating:
			donaldduck.y = jump
		elif y < .5:
			velocity.y = jump
			trick[0] = 250
			trick[1] = "Ollie"
		jumping = true
	if jumping and skating:
		airtime += 1
	if !skating:
		if moving:
			if Input.is_action_pressed("move_forward"):
				direction -= transform.basis.z
			elif Input.is_action_pressed("move_back"):
				direction += transform.basis.z
			if Input.is_action_pressed("move_left"):
				direction -= transform.basis.x
			elif Input.is_action_pressed("move_right"):
				direction += transform.basis.x
		direction = direction.normalized()
		velocity = direction * speed
		velocity = velocity.rotated(Vector3.UP, look.rotation.y - rotation.y)
		if !is_on_floor():
			donaldduck.y -= gravity * delta
		velocity.y += donaldduck.y
		if !jumping or (jumping and !is_on_floor()):
			velocity.y = move_and_slide_with_snap(velocity, snapdirection * snaplength, Vector3.UP, true, 4, 
			deg2rad(60)).y
		if jumping and is_on_floor():
			velocity.y = move_and_slide_with_snap(velocity, snapdirection * 0, Vector3.UP, false).y
			jumping = false
		var slides = get_slide_count()
		if slides:
			for i in slides:
				var touched = get_slide_collision(i)
				if is_on_floor() && touched.normal.y < 1 && (velocity.x != 0 || velocity.z != 0):
					velocity.y = touched.normal.y
		sprite.play("default")
	else:
		if !grinding:
			if y < .5 and jumping and airtime > 10:
				jumping = false
				emit_signal("landed")
				trick[0] = 0
				trick[1] = "nothing"
				airtime = 0
			if !Input.is_action_pressed("brake") and moving:
				if Input.is_action_pressed("move_forward"):
					direction -= transform.basis.z
					acceleration = lerp(acceleration, 5, .0002)
					speed = lerp(speed, 8, .2)
				elif Input.is_action_pressed("move_back"):
					direction += transform.basis.z
					acceleration = lerp(acceleration, 5, .0002)
					speed = lerp(speed, 8, .2)
				if Input.is_action_pressed("move_left"):
					direction -= transform.basis.x
					acceleration = lerp(acceleration, 5, .0002)
					speed = lerp(speed, 8, .2)
				elif Input.is_action_pressed("move_right"):
					#direction = direction.slerp((direction + transform.basis.x).normalized(), .02).normalized()
					direction += transform.basis.x
					acceleration = lerp(acceleration, 5, .0002)
					speed = lerp(speed, 8, .2)
			if y <= .5: 
				var n = $down.get_collision_normal()
				global_transform = align(global_transform, n)
			else:
				global_transform = align(global_transform, global_transform.basis.y - Vector3.DOWN)
			if nogrind < 1 and $look/grind.is_colliding() and $look/side.is_colliding() and Input.is_action_pressed("grind"):
				grinding = true
			velocity.y -= gravity * delta
		else:
			if Input.is_action_just_released("grind"):
				grinding = false
			owner.get_node("interface").addcombo(1)
			global_transform = align(global_transform, $look/grind.get_collision_point().linear_interpolate($look/side.get_collision_point(), 0.5))
		acceleration = lerp(acceleration, .5, .0001)
		speed = lerp(speed, 1, .1)
		direction = direction.rotated(Vector3.UP, look.rotation.y - rotation.y)
		sprite.look_at(direction + global_transform.origin, Vector3.UP)
		var o = rad2deg(sprite.rotation.y - (look.rotation.y + rotation.y))
		while o < -180:
			o += 360
		while o > 180:
			o -= 360
		if (o > -24 and o < 1) or (o < 23 and o > -1):
			sprite.play("skate1")
		elif o > 22 and o < 68:
			sprite.play("skate8")
		elif o > 67 and o < 113:
			sprite.play("skate7")
		elif o > 112 and o < 158:
			sprite.play("skate6")
		elif o > 157 or o < -158:
			sprite.play("skate5")
		elif o > -159 and o < -113:
			sprite.play("skate4")
		elif o > -114 and o < -68:
			sprite.play("skate3")
		elif o > -69 and o < -23:
			sprite.play("skate2")
		direction = direction.normalized()
		velocity = velocity.linear_interpolate(direction * speed * 2.5, acceleration * delta)
		velocity = move_and_slide(velocity, Vector3.UP)
	#if Input.is_action_just_released("grind") or Input.is_action_just_pressed("jump"):
	#	nogrind += 10
	#if y < .5 and rotation == Vector3():
	#	boar.look_at(global_transform.origin + direction - Vector3(0, .48, 0), Vector3.UP)

func align(xform, y):
	xform.basis.y = y
	xform.basis.x = -xform.basis.z.cross(y)
	xform.basis = xform.basis.orthonormalized()
	return xform

func die():
	$board.mode = RigidBody.MODE_RIGID
	$board.add_child(board)
