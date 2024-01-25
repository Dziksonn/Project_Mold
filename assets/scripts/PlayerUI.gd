extends CanvasLayer

var Store_hp = 50
var Store_enemies = 0
var Store_coins = 0
var Store_maxhp = 100

func set_hud_visible(status : bool):
	$hud.visible = status

func set_death_screen(status : bool):
	$death_screen.visible = status

func refresh():
	$hud/TextureProgressBar.max_value = Store_maxhp
	$hud/TextureProgressBar.value = Store_hp
	$hud/enemy_kills/RichTextLabel.set_text(str(Store_enemies))
	$hud/money/RichTextLabel.set_text(str(Store_coins))
	$hud/TextureProgressBar/hp_text.set_text("[center]" + str(Store_hp) + "/" + str(Store_maxhp) + "[/center]")

func _ready():
	$death_screen.visible = false


func _on_button_pressed():
	print("Button pressed")
	set_death_screen(false)
	SceneTransition.change_scene("res://assets/scenes/lobby.tscn")
