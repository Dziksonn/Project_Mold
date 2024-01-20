extends Node

signal player_heal
signal player_damage(number)
signal player_died

var Player_data : Dictionary = {"hp" = 50, "max_hp" = 100, "is_dead" = false, "coins" = 0}
var actual_scene : String
var boss_fight : bool = false
var show_hud : bool = true

func set_scene(scene_name):
	actual_scene = scene_name
	match actual_scene:
		"boss_scene":
			boss_fight = true
			PlayerUi.set_hud_visible(true)
		"menu":
			boss_fight = true
			show_hud = false
			PlayerUi.set_hud_visible(false)
		"lobby":
			boss_fight = false
			show_hud = false
			PlayerUi.set_hud_visible(false)
		_: #default
			boss_fight = false
			show_hud = true
			PlayerUi.set_hud_visible(true)


func refresh_hud():
	PlayerUi.store_hp = Player_data.hp
	PlayerUi.refresh()

func _damage_player(number):
	Player_data.hp -= number
	if Player_data.hp <= 0:
		kill_player()
	print("Damage")
	print(Player_data.hp)

func _heal_player():
	Player_data.hp = Player_data.max_hp
	print("Heal")
	print(Player_data.hp)

func kill_player():
	Player_data.is_dead = true
	player_died.emit()


func _ready():
	player_heal.connect(_heal_player)
	player_damage.connect(_damage_player)
	pass

func _process(_delta):
	refresh_hud()
