extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_entered(area:Area2D):
	if area.name == "PlayerDetector":
		shop_state(true)


func shop_state(state):
	ShopMenu.visible = state
	ShopMenu.refresh_coins()

func _on_area_exited(area:Area2D):
	if area.name == "PlayerDetector":
		shop_state(false)
