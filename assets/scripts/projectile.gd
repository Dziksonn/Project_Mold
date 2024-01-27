extends RigidBody2D

var rng = RandomNumberGenerator.new()
var damage = 10

func _ready():
	await get_tree().create_timer(2).timeout
	$AnimationPlayer.play("dissolve")
	await $AnimationPlayer.animation_finished
	queue_free()

func _on_hitbox_area_entered(area):
	area.get_parent().receiveDamage(damage,Vector2(0,0))
	if Global.Player_temp_data["powerups"]["bleeding"] > 0:
		area.get_parent()._bleed(Global.Player_temp_data["powerups"]["bleeding"],damage/Global.Player_temp_data["powerups"]["bleeding"])
