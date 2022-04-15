extends RigidBody

class_name npc

signal next

onready var player = get_parent().get_node("player")
onready var text = get_parent().get_node("camera/cam/interface/box/dialogue")

onready var sprite = $sprite
onready var sound = $voice
onready var area = $range
var talking = false
var dialoging = false
var cooldown = 0

export var words : Array
export var appearance : SpriteFrames
export var voice : AudioStream

func _ready():
	for w in words:
		if !w is String:
			words.erase(w)
	sprite.set_sprite_frames(appearance)
	sound.set_stream(voice)
	dialoging = false

func _process(delta):
	set_mode(RigidBody.MODE_STATIC)
	if cooldown > 0:
		cooldown -= 1
	for p in area.get_overlapping_bodies():
		if p == player:
			if dialoging:
				player.moving = false
				if player.skating:
					player.skating = false
					player.shape.set_disabled(false)
					player.board.set_disabled(true)
					player.speed = 6
					player.boar.set_visible(false)
			else:
				player.moving = true
			if Input.is_action_just_pressed("a") and !talking and !player.grinding:
				if !text.dialoging and cooldown <= 0:
					talking = true
					text.say(self)
				elif text.dialoging:
					if talking == false:
						talking = true
						emit_signal("next")
			if p.global_transform.origin.x > global_transform.origin.x:
				sprite.flip_h = false
			elif p.global_transform.origin.x < global_transform.origin.x:
				sprite.flip_h = true
		elif !text.writing:
			talking = false
	if talking:
		sprite.playing = true
		if !sound.playing:
			sound.playing = true
	else:
		sprite.playing = false
		sound.playing = false
		sprite.set_frame(0)

func stop():
	sprite.playing = false
	sound.playing = false
	sprite.set_frame(0)
