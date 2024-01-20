extends CanvasLayer

var store_hp = 50

func _ready():
	pass

func _process(_delta):
	pass


func set_hud_visible(status : bool):
	self.visible = status


func refresh():
	$TextureProgressBar.value = store_hp