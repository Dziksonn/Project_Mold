extends Node

signal refresh_stats
signal player_heal
signal player_damage(number)
signal player_died
signal enemy_killed()
signal coins_earned(number)
signal add_item(Item)

var All_items: Dictionary = {
	0:preload("res://assets/Items/HealthUpTestItem.tres"),
	1:preload("res://assets/Items/TestItem.tres"),
	2:preload("res://assets/Items/DoorItem.tres"),
	3:preload("res://assets/Items/Spoon.tres")
}

var Player_Items:Array[Item]
var Player_temp_data : Dictionary = {
	"attack_power" = 10,
	"attack_speed" = 1,
	"movement_speed" = 400,
	"hp" = 100, 
	"max_hp" = 100, 
	"is_dead" = false, 
	"enemy_kills_per_run" = 0,
	"powerups" = {
		"multishot":1,
		"lifesteal":0
	}}
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
	PlayerUi.Store_maxhp = Player_temp_data.max_hp
	PlayerUi.Store_enemies = Player_temp_data.enemy_kills_per_run
	PlayerUi.Store_coins = Player_data.coins
	PlayerUi.refresh()

func _damage_player(number):
	Player_temp_data.hp -= number
	if Player_temp_data.hp <= 0:
		kill_player()
	#print("Damage")
	#print(Player_temp_data.hp)

func heal_player(amount):
	Player_temp_data["hp"] += amount
	if Player_temp_data["hp"] > Player_temp_data["max_hp"]:
		Player_temp_data["hp"] = Player_temp_data["max_hp"]

func kill_player():
	Player_temp_data.is_dead = true
	player_died.emit()

func _enemy_killed():
	print(Player_data.enemy_kills)
	Player_data.enemy_kills += 1
	Player_temp_data.enemy_kills_per_run += 1
	heal_player(Player_temp_data["powerups"]["lifesteal"])
	
	

func _coins_earned(number):
	Player_data.coins += number

func _ready():
	print(All_items[0].name)
	player_damage.connect(_damage_player)
	enemy_killed.connect(_enemy_killed)
	coins_earned.connect(_coins_earned)
	add_item.connect(_add_item)
	pass

func _process(_delta):
	refresh_hud()

func _add_item(item:Item):
	Player_Items.append(item)
	#Nie ma sensu chyba robic osobnej funkcji od update_stats() wiec zrobie to tu :p
	for upgrade in item.statUpgrades:
		match upgrade:
			"MaxHealth":
				Player_temp_data["max_hp"] += item.statUpgrades[upgrade]
			"MovementSpeed":
				Player_temp_data["movement_speed"] += item.statUpgrades[upgrade]
			"AttackSpeed":
				Player_temp_data["attack_speed"] += item.statUpgrades[upgrade]
			"Multishot":
				if Player_temp_data["powerups"]["multishot"] == 5:
					continue
				Player_temp_data["powerups"]["multishot"]+=2
			"AttackPower":
				Player_temp_data["attack_power"]+= item.statUpgrades[upgrade]
			"Lifesteal":
				Player_temp_data["powerups"]["lifesteal"]+= item.statUpgrades[upgrade]
	refresh_hud()
	Global.refresh_stats.emit()
