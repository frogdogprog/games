extends Path

class_name edge

export var vertices : Array

onready var player = get_tree().get_root().get_node("epic/player")
onready var move = $move
var distance = 100
var position

func _ready():
	for p in vertices:
		if p is Vector3:
			curve.add_point(p)

func _process(delta):
	#print(distance < .8 and player.global_transform.origin.y - position.y >= .6 and player.skating and !player.grinding and player.nogrind < 1)
	position = curve.get_closest_point(to_local(player.global_transform.origin))
	distance = position.distance_to(player.global_transform.origin)
	move.offset = curve.get_closest_offset(to_local(player.global_transform.origin)) #offset when going past the right is wrong
	if Input.is_action_pressed("grind") and (distance < .8 and 
	player.global_transform.origin.y - position.y >= .1 and player.skating and 
	!player.grinding and player.nogrind < 1) and false:
		player.global_transform.origin = position
		player.grinding = true
	if player.grinding:
		var d = to_local(player.global_transform.origin) + player.velocity * curve.get_baked_length() * 5
		if d.distance_to(curve.get_point_position(0)) < d.distance_to(curve.get_point_position(curve.get_point_count() - 1)):
			move.offset -= player.speed * player.acceleration * .01
		elif d.distance_to(curve.get_point_position(0)) > d.distance_to(curve.get_point_position(curve.get_point_count() - 1)):
			move.offset += player.speed * player.acceleration * .01
		player.global_transform.origin = move.global_transform.origin
		if move.unit_offset <= .05 or move.unit_offset >= .95:
			player.nogrind += 10
			player.grinding = false
