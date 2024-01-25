extends Node

signal refresh_stats
signal player_heal
signal player_damage(number)
signal player_died
signal enemy_killed()
signal coins_earned(number)
signal add_item(Item)

var All_items: Dictionary = {
	"common":{
		0:preload("res://assets/Items/Cutting_board.tres"),
		1:preload("res://assets/Items/Spoon.tres"),
		2:preload("res://assets/Items/Fork.tres"),
		},
	"rare":{
		0:preload("res://assets/Items/Knife.tres"),
		1:preload("res://assets/Items/Salt.tres"),
		2:preload("res://assets/Items/Pepper.tres"),
	},


}
var Items_to_obtain:Dictionary = All_items

var Player_Items:Array[Item]
var Player_Perma_Items : Dictionary = {
	"fork": {
		"bought" = false,
		"price" = 100,
		"stats" = {
			"attack_power" = 100
		}
	}
}
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
		"lifesteal":0,
		"bleeding":0
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
			reset_buffs()
			PlayerUi.set_hud_visible(false)
			print("test")
		"intro":
			boss_fight = false
			show_hud = false
			PlayerUi.set_hud_visible(false)
		_: #default
			boss_fight = false
			show_hud = true
			PlayerUi.set_hud_visible(true)


func reset_buffs():
	Player_temp_data = {
		"attack_power" = 10,
		"attack_speed" = 1,
		"movement_speed" = 400,
		"hp" = 100,
		"max_hp" = 100,
		"is_dead" = false,
		"enemy_kills_per_run" = 0,
		"powerups" = {
			"multishot":1,
			"lifesteal":0,
			"bleeding":0
		}}
	for item in Player_Perma_Items:
		if Player_Perma_Items[item]["bought"] == true:
			for stat in Player_Perma_Items[item]["stats"]:
				Player_temp_data[stat] += Player_Perma_Items[item]["stats"][stat]

func buy_item(name):
	if Player_data["coins"] >= Player_Perma_Items[name]["price"]:
		Player_data["coins"] -= Player_Perma_Items[name]["price"]
		Player_Perma_Items[name]["bought"] = true
		reset_buffs()
		Global.refresh_stats.emit()
		return true
	else:
		return false


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

func heal_player(amount):
	Player_temp_data["hp"] += amount
	if Player_temp_data["hp"] > Player_temp_data["max_hp"]:
		Player_temp_data["hp"] = Player_temp_data["max_hp"]

func kill_player():
	Player_temp_data.is_dead = true
	player_died.emit()

func _enemy_killed():
	Player_data.enemy_kills += 1
	Player_temp_data.enemy_kills_per_run += 1
	heal_player(Player_temp_data["powerups"]["lifesteal"])



func _coins_earned(number):
	Player_data.coins += number

func _ready():
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
			"Bleeding":
				Player_temp_data["powerups"]["bleeding"]+= item.statUpgrades[upgrade]
				for _item in Player_Items:
					if _item.name == "Pepper":
						Player_temp_data["powerups"]["bleeding"]+= item.statUpgrades[upgrade]
			"BleedingEnchance":
				for _item in Player_Items:
					if _item.name == "Salt":
						Player_temp_data["powerups"]["bleeding"] += Player_temp_data["powerups"]["bleeding"]
	Global.refresh_stats.emit()
