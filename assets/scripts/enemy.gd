extends CharacterBody2D

@export var max_health = 200
var health = max_health

@export var speed = 360
@export var accel = 7
@export var attack_player = false
@export var damage = 1

var target_node = null
var home_pos = Vector2.ZERO

var rng = RandomNumberGenerator.new()

@onready var nav : NavigationAgent2D = $NavigationAgent2D
@onready var player : CharacterBody2D = owner.get_node("Player")

var knockbacked : bool = false
var knock_direction_physics : Vector2 = Vector2()

func _ready():
	home_pos = self.global_position
	nav.path_desired_distance = 8
	nav.target_desired_distance = 8
	$HealthBar.max_value = max_health
	$HealthBar.value = health
	set_physics_process(false)
	await get_tree().physics_frame
	set_physics_process(true)
	$Hitbox.body_entered.connect(OnBodyEntered)
	$Hitbox.body_exited.connect(OnBodyExited)

func receiveDamage(amount, knock_direction : Vector2):
	target_node = player
	health -= amount
	$HealthBar.value = health
	$AudioStreamPlayer2D.play()
	$Dummy.modulate	= Color(1, 0.4, 0.4)
	knockback(knock_direction)
	if health <= 0:
		die()
	await get_tree().create_timer(0.2).timeout
	$Dummy.modulate	= Color(1, 1, 1)

func _bleed(ticks, amount):
	await get_tree().create_timer(0.4).timeout
	for i in range(ticks):
		print(i)
		receiveDamage(amount, Vector2(0,0))
		await get_tree().create_timer(1).timeout

func die():
	$AnimationPlayer.play('ded')
	await $AnimationPlayer.animation_finished
	drop_item()
	queue_free()
	Global.enemy_killed.emit()
	Global.coins_earned.emit(20)

func drop_item():
	var rarity
	if(rng.randf_range(0,100) >= 25):
		if(rng.randf_range(0,100) >= 25):
			rarity = "rare"
		else:
			rarity = "common"

		var items_to_obtain = Global.Items_to_obtain[rarity]
		var size = items_to_obtain.size()-1
		if size >= 0:
			var rand = rng.randi_range(0,size)
			var ItemToDrop = items_to_obtain[items_to_obtain.keys()[rand]]
			items_to_obtain.erase(items_to_obtain.find_key(ItemToDrop))
			var ItemDropObject = preload("res://assets/scenes/dropped_item.tscn").instantiate()
			ItemDropObject.position = self.position
			ItemDropObject.get_child(0).texture = ItemToDrop.texture
			ItemDropObject.itemToAdd = ItemToDrop
			get_tree().get_root().get_node(".").add_child(ItemDropObject)

func knockback(knok_direction):
	knock_direction_physics = knok_direction
	knockbacked = true
	await get_tree().create_timer(0.1).timeout
	knockbacked = false

func _physics_process(delta):
	if nav.is_navigation_finished():
		return
	
	var axis = to_local(nav.get_next_path_position()).normalized()
	velocity = axis*speed
	move_and_slide()
	

	#var direction = Vector3()
#
	#if is_instance_valid(player):
#
		#nav.target_position = player.position
		#direction = nav.get_next_path_position() - global_position
		#direction = direction.normalized()
		#if knockbacked:
			#direction = knock_direction_physics * 10
#
		#velocity = velocity.lerp(direction * speed, accel * delta)
#
		#move_and_slide()

func recalc_path():
	if target_node:
		nav.target_position = target_node.global_position
	else:
		nav.target_position = home_pos

func OnBodyEntered(body):
	if (body.name == "Player"):
		attack_player = true
		while attack_player:
			Global.player_damage.emit(damage)
			await get_tree().create_timer(0.5).timeout

func OnBodyExited(body):
	if (body.name == "Player"):
		attack_player = false


func _on_recalculate_timer_timeout():
	recalc_path()

func _on_area_2d_area_entered(area):
	target_node = player

func _on_area_2d_area_exited(area):
	target_node = null

