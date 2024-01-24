extends RigidBody2D

var rng = RandomNumberGenerator.new()

func _ready():
	await get_tree().create_timer(2).timeout
	$AnimationPlayer.play("dissolve")
	await $AnimationPlayer.animation_finished
	queue_free()

func _on_hitbox_area_entered(area):
	var attackpower = Global.Player_temp_data["attack_power"]
	var Damage = rng.randi_range(attackpower-5,attackpower+5)
	area.get_parent().receiveDamage(Damage*2,Vector2(0,0))
	if Global.Player_temp_data["powerups"]["bleeding"] > 0:
		area.get_parent()._bleed(Global.Player_temp_data["powerups"]["bleeding"],Damage*2/Global.Player_temp_data["powerups"]["bleeding"])
