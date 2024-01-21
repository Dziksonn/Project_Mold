extends Node

signal player_heal
signal player_damage(number)
signal player_died
signal enemy_killed()
signal coins_earned(number)

var Player_temp_data : Dictionary = {"hp" = 500, "max_hp" = 100, "is_dead" = false, "enemy_kills_per_run" = 0}
var Player_data : Dictionary = {"coins" = 0, "enemy_kills" = 0}
var actual_scene : String
var boss_fight : bool = false
var show_hud : bool = true

func set_scene(scene_name):
	actual_scene = scene_name
	match actual_scene:
		"boss_scene":
			boss_fight = false
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
	PlayerUi.Store_hp = Player_temp_data.hp
	PlayerUi.Store_enemies = Player_temp_data.enemy_kills_per_run
	PlayerUi.Store_coins = Player_data.coins
	PlayerUi.refresh()

func _damage_player(number):
	Player_temp_data.hp -= number
	if Player_temp_data.hp <= 0:
		kill_player()
	print("Damage")
	print(Player_temp_data.hp)

func _heal_player():
	Player_temp_data.hp = Player_temp_data.max_hp
	print("Heal")
	print(Player_temp_data.hp)

func kill_player():
	Player_temp_data.is_dead = true
	player_died.emit()

func _enemy_killed():
	print(Player_data.enemy_kills)
	Player_data.enemy_kills += 1
	Player_temp_data.enemy_kills_per_run += 1

func _coins_earned(number):
	Player_data.coins += number


func _ready():
	player_heal.connect(_heal_player)
	player_damage.connect(_damage_player)
	enemy_killed.connect(_enemy_killed)
	coins_earned.connect(_coins_earned)
	pass

func _process(_delta):
	refresh_hud()
