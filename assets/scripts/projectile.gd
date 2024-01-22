extends RigidBody2D

@export var Damage = 10

func _ready():
	await get_tree().create_timer(2).timeout
	queue_free()

func _on_hitbox_area_entered(area):
	area.get_parent().receiveDamage(Damage,Vector2(0,0))
