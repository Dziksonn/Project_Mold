extends Sprite2D

@export var Health = 200

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func GetDamaged(Amount):
	Health-=Amount
	print(Health)
