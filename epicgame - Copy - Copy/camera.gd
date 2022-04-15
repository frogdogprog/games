extends Spatial

onready var player = get_parent().get_node("player")
var characters = []
var focus = Vector3()
onready var cam = $cam
onready var box = $cam/interface/box
onready var point = $cam/interface/point
onready var text = $cam/interface/box/dialogue
var location : Vector2
var stem = Vector2(0, 250)

func _ready():
	$cam/interface.visible = false
	cam.set_current(true)
	for t in get_parent().get_children():
		if t is npc:
			characters.append(t)
	box.rect_position = Vector2(540, 150)
	focus = player.global_transform.origin

func _input(event):
	if Input.is_action_pressed("pan"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if event is InputEventMouseMotion:
			rotate_y(deg2rad(-event.relative.x * .2))
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	if Input.is_action_pressed("left"):
		rotate_y(deg2rad(.5))
	elif Input.is_action_pressed("right"):
		rotate_y(deg2rad(-.5))
	if Input.is_action_pressed("phone"):
		cam.current = false
	else:
		cam.current = true
	if player.moving:
		global_transform.origin = player.global_transform.origin
	else:
		global_transform.origin = (player.global_transform.origin * 0.5) + (focus * 0.5)
	for i in characters:
		if text.dialoging and i.dialoging:
			box.visible = true
			point.visible = true
			focus = i.global_transform.origin
	location = cam.unproject_position(focus)
	box.rect_position.x = clamp(lerp(box.rect_position.x, location.x * 2 - 740, 0.1), 240, 1040)
	stem.x = clamp(location.x * 2 - 640, 320, 960)
	#box.rect_position = (location * 0.5) + (stem * 0.5) + Vector2(-20, -20)
	point.set_polygon(PoolVector2Array([Vector2(stem.x - 20, 250), Vector2(stem.x + 20, 250), 
	(location * 0.5) + (stem * 0.5)]))
	#visible_characters = lapsed / 0.1
