extends RichTextLabel

signal done

var lapsed = 0
var writing = false
var amount : int
var dialoging

func _ready():
	lapsed = 0
	set_visible_characters(0)
	visible = false
	dialoging = false

func _process(delta):
	if writing:
		lapsed += delta
		set_visible_characters(lapsed / .04)
		if get_visible_characters() >= amount:
			emit_signal("done")
		if Input.is_action_just_pressed("a"):
			lapsed = amount

func say(c : npc):
	get_parent().get_parent().visible = true
	visible = true
	dialoging = true
	c.dialoging = true
	c.mode = RigidBody.MODE_STATIC
	for d in c.words:
		set_visible_characters(0)
		text = d
		writing = true
		amount = d.length()
		yield(self, "done")
		c.talking = false
		writing = false
		yield(c, "next")
		lapsed = 0
	c.cooldown = 100
	dialoging = false
	c.dialoging = false
	c.mode = RigidBody.MODE_RIGID
	visible = false
	get_parent().get_parent().visible = false
