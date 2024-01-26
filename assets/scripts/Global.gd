extends Node

signal refresh_stats
signal player_heal
signal player_damage(number)
signal player_died
signal enemy_killed()
signal coins_earned(number)
signal add_item(Item)

var actual_scene : String
var boss_fight : bool = false
var show_hud : bool = true

var All_items: Dictionary = {
	"common":{
		0:preload("res://assets/Items/Cutting_board.tres"),
		1:preload("res://assets/Items/Spoon.tres"),
		2:preload("res://assets/Items/Fork.tres"),
		3:preload("res://assets/Items/Rolling_pin.tres"),
		4:preload("res://assets/Items/Towel.tres")
		},
	"rare":{
		0:preload("res://assets/Items/Knife.tres"),
		1:preload("res://assets/Items/Salt.tres"),
		2:preload("res://assets/Items/Pepper.tres"),
		3:preload("res://assets/Items/Not_a_pan.tres"),
		4:preload("res://assets/Items/Chopper.tres")
	},
}
var Items_backup = All_items.duplicate(true)
var Items_to_obtain:Dictionary = All_items.duplicate(true)
var Player_Items:Array[Item]
var Player_Perma_Items : Dictionary = {
	"fork": {
		"bought" = false,
		"price" = 100,
		"stats" = {
			"attack_power" = 5
		}
	},
	"sponge": {
		"bought" = false,
		"price" = 1000,
		"stats" = {
			"movement_speed" = 100,
			"attack_power" = 5
		}
	}
}
var Player_temp_data : Dictionary = {
	"attack_power" = 10,
	"attack_speed" = 1,
	"movement_speed" = 4000,
	"hp" = 100,
	"max_hp" = 100,
	"is_dead" = false,
	"enemy_kills_per_run" = 0,
	"powerups" = {
		"multishot":1,
		"lifesteal":0,
		"bleeding":0
	}}
var Player_data : Dictionary = {
	"coins" = 0,
	"enemy_kills" = 0
}

func set_scene(scene_name):
	actual_scene = scene_name
	match actual_scene:
		"boss_scene":
			handle_scene_change(false, true)
		"menu":
			handle_scene_change(true, false)
		"lobby":
			reset_buffs()
			handle_scene_change(false, false)
		"intro":
			handle_scene_change(false, false)
		"dead":
			handle_scene_change(false, false)
		_: #default
			handle_scene_change(false, true)

func handle_scene_change(temp_boss_fight, hud):
	boss_fight = temp_boss_fight
	show_hud = hud
	PlayerUi.set_hud_visible(hud)

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
	All_items = Items_backup.duplicate(true)
	Items_to_obtain = Dictionary(All_items)
	for item in Player_Perma_Items:
		if Player_Perma_Items[item]["bought"] == true:
			for stat in Player_Perma_Items[item]["stats"]:
				Player_temp_data[stat] += Player_Perma_Items[item]["stats"][stat]

func buy_item(item_name):
	if Player_data["coins"] >= Player_Perma_Items[item_name]["price"]:
		Player_data["coins"] -= Player_Perma_Items[item_name]["price"]
		Player_Perma_Items[item_name]["bought"] = true
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

func heal_player(amount):
	Player_temp_data["hp"] += amount
	if Player_temp_data["hp"] > Player_temp_data["max_hp"]:
		Player_temp_data["hp"] = Player_temp_data["max_hp"]

func kill_player():
	Player_temp_data.is_dead = true
	player_died.emit()

func _damage_player(number):
	Player_temp_data.hp -= number
	if Player_temp_data.hp <= 0:
		PlayerUi.set_hud_visible(false)
		kill_player()

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

func _add_item(item:Item):
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
						Player_temp_data["powerups"]["bleeding"]+= 1
			"BleedingEnchance":
				for _item in Player_Items:
					if _item.name == "Salt":
						Player_temp_data["powerups"]["bleeding"] += 1
	Global.refresh_stats.emit()

func _process(_delta):
	refresh_hud()
