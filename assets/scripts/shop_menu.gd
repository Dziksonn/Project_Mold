extends Control

@onready var items : Dictionary = {
	"fork": {
		"button": $Fork_Button,
		"colorRect": $Fork_Button/ColorRect,
	},
	"sponge":{
		"button": $Sponge_Button,
		"colorRect":$Sponge_Button/ColorRect
	}
}


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	refresh_coins()
	for x in Global.Player_Perma_Items:
		if Global.Player_Perma_Items[x]["bought"] == true:
			if x in items:
				items[x]["button"].disabled = true

func refresh_coins():
	$coin_amount.text = str(Global.Player_data["coins"])

func button_press(item_name):
	var button = items[item_name]["button"]
	var colorRect = items[item_name]["colorRect"]
	var buy = Global.buy_item(item_name)

	if buy == true:
		button.disabled = true
	else:
		colorRect.visible = true
		await get_tree().create_timer(0.2).timeout
		colorRect.visible = false
	refresh_coins()

func _on_fork_button_pressed():
	button_press("fork")

func _on_sponge_button_pressed():
	button_press("sponge")
