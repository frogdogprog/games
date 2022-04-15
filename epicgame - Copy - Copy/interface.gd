extends Container

onready var player = get_parent().get_node("player")

export var score : int = 0
var displayscore = 0
export var combo : int = 0
var displaycombo = 0
onready var scor = $score
onready var comb = $combo
onready var time = $time

onready var tween = $tween

var combotime = 1000
var comboing = false

func _ready():
	time.max_value = 1000
	player.connect("landed", self, "addcombo", [player.trick[0], player.trick[1]])

func _process(delta): 
	if comboing:
		combotime -= 1
		if combotime < 1:
			comboing = false
			_deposit()
	if player.grinding:
		addcombo(1, "Grind")
	time.visible = comboing
	time.value = combotime
	scor.text = str(displayscore)
	comb.visible = comboing
	comb.text = str(displaycombo)
	displayscore = stepify(lerp(displayscore, score, .1), 1)
	displaycombo = stepify(lerp(displaycombo, combo, .1), 1)
	if displayscore < score:
		displayscore += 1
	if displayscore > score:
		displayscore -= 1
	if displaycombo < combo:
		displaycombo += 1
	if displaycombo > combo:
		displaycombo -= 1

func addcombo(a : int, t : String):
	if !comboing:
		combotime = 1000
		comboing = true
	combo += a
	displaycombo = lerp(displaycombo, combo, 2)
	if a > 249:
		combotime += a * .2
	else:
		combotime += 1

func _deposit():
	score += combo
	combo = 0
