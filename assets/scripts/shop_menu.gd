extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	refresh_coins()
	for x in Global.Player_Perma_Items:
		if Global.Player_Perma_Items[x]["bought"] == true:
			match x:
				"fork":
					$Fork_Button.disabled = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func refresh_coins():
	$coin_amount.text = str(Global.Player_data["coins"])


func _on_fork_button_pressed():
	var buy = Global.buy_item("fork")
	if buy == true:
		$Fork_Button.disabled = true
	else:
		$Fork_Button/ColorRect.visible = true
		await get_tree().create_timer(0.2).timeout
		$Fork_Button/ColorRect.visible = false

	refresh_coins()

