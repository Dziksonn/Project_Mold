extends Node
signal Player_toggle_noclip
var Status = false
var godmode = false
var noclip = false
var default_collision_layer
var default_collision_mask

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
		[b]L[/b]obby teleport\n
		[b]N[/b]oclip\n
		[b]Up[/b] Heal\n
		[b]Down[/b] Damage\n
		[b]Health[/b] {hp}/{maxHealth}\n
		[b]Attack Speed[/b] {attackSpeed}\n
		[b]Attack Power[/b] {attackPower}\n
		[b]Multishot[/b] {multishot}\n
		[b]Movement Speed[/b] {movementSpeed}
		"
		.format({
			"status": Global.boss_fight,
			"attackPower" : Global.Player_temp_data["attack_power"],
			"attackSpeed" : Global.Player_temp_data["attack_speed"],
			"movementSpeed" : Global.Player_temp_data["movement_speed"],
			"maxHealth" : Global.Player_temp_data["max_hp"],
			"hp" : Global.Player_temp_data["hp"],
			"multishot" : Global.Player_temp_data["powerups"]["multishot"]
			}))

func toggle_godmode():
	godmode = !godmode
	Ui_update()

func toggle_bossmode():
	Global.boss_fight = !Global.boss_fight
	Ui_update()

func toggle_noclip():
	noclip = !noclip
	Ui_update()
	emit_signal("Player_toggle_noclip", noclip)

func heal_player():
	Global.heal_player(20000)

func damage_player():
	Global.player_damage.emit(10)

func _process(_delta):
	var dev_godmode = Input.is_action_just_pressed("dev_godmode")
	var dev_boss_mode = Input.is_action_just_pressed("dev_bossmode")
	var dev_tp_lobby = Input.is_action_just_pressed("dev_tp_lobby")
	var dev_noclip = Input.is_action_just_pressed("dev_noclip")
	var dev_heal = Input.is_action_just_pressed("dev_heal")
	var dev_damage = Input.is_action_just_pressed("dev_damage")
	if dev_godmode:
		toggle_godmode()
	if dev_boss_mode:
		toggle_bossmode()
	if dev_tp_lobby:
		SceneTransition.change_scene("res://assets/scenes/lobby.tscn")
	if dev_noclip:
		toggle_noclip()
	if dev_heal:
		heal_player()
	if dev_damage:
		damage_player()
	Ui_update()
