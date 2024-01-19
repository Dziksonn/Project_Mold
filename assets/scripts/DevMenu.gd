extends Node
var Status = false
var godmode = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func Toggle():
	Status = !Status
	Ui_update()


func Ui_update():
	if Status == true:
		self.visible = true
		process_mode = Node.PROCESS_MODE_INHERIT
	else:
		self.visible = false
		process_mode = Node.PROCESS_MODE_DISABLED
	$RichTextLabel.set_text("
		[b]B[/b]oss Mode: {status}\n
		[b]L[/b]obby teleport
		"
		.format({"status": Global.boss_fight}))

func toggle_godmode():
	godmode = !godmode
	Ui_update()

func toggle_bossmode():
	Global.boss_fight = !Global.boss_fight
	Ui_update()

func _process(_delta):
	var dev_godmode = Input.is_action_just_pressed("dev_godmode")
	var dev_boss_mode = Input.is_action_just_pressed("dev_bossmode")
	var dev_tp_lobby = Input.is_action_just_pressed("dev_tp_lobby")
	if dev_godmode:
		toggle_godmode()
	if dev_boss_mode:
		toggle_bossmode()
	if dev_tp_lobby:
		SceneTransition.change_scene("res://assets/scenes/lobby.tscn")
