extends CanvasLayer

var Store_hp = 50
var Store_enemies = 0
var Store_coins = 0
var Store_maxhp = 100

func set_hud_visible(status : bool):
	self.visible = status


func refresh():
	$TextureProgressBar.max_value = Store_maxhp
	$TextureProgressBar.value = Store_hp
	$enemy_kills/RichTextLabel.set_text(str(Store_enemies))
	$money/RichTextLabel.set_text(str(Store_coins))
