extends CharacterBody2D

@export var jump_velocity = -500
@export var gravity = 900

var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var freeze = false
var force = "off"
var dev_ui
var canAttack = true
var attackSpeed = 1 # = 1 attack per seccond
var projectileSpeed = 1500
var facingDirectionVector : Vector2
var cooldown = 0
var alt_cooldown = 0
var gamepad = false
var gamepad_countdown = 0

var rng = RandomNumberGenerator.new()

func _ready():
	screen_size = get_viewport_rect().size
	Global.set_scene(get_parent().name)
	DevMenu.Ui_update()
	DevMenu.Player_toggle_noclip.connect(_player_toggle_noclip)
	Global.player_died.connect(_kill_player)
	Global.player_damage.connect(_player_damage)
	Global.refresh_stats.connect(_refreshStats)
	_refreshStats()
	
func _process(delta):
	cooldown -= delta
	alt_cooldown -= delta
	$Control/TextureProgressBar.value = alt_cooldown
	var controls = {
		move_right = Input.is_action_pressed("move_right"),
		move_left = Input.is_action_pressed("move_left"),
		move_down = Input.is_action_pressed("move_down"),
		move_up = Input.is_action_pressed("move_up"),
		dev_menu = Input.is_action_just_pressed("dev_menu"),
		attack = Input.is_action_just_pressed("attack"),
		alt_attack = Input.is_action_just_pressed("attack_alt")
	}
	var controls_gamepad = {
		direction_y = Input.get_action_strength("look_y_plus") - Input.get_action_strength("look_y_minus"),
		direction_x = Input.get_action_strength("look_x_plus") - Input.get_action_strength("look_x_minus"),
	}
	if freeze:
		for key in controls:
			controls[key] = false

	if force != "off":
		match(force):
			"right":
				controls.move_right = true
			"left":
				controls.move_left = true
			"down":
				controls.move_down = true
			"up":
				controls.move_up = true

	if !Global.boss_fight:
		normal_movement(controls)
	else:
		boss_movement(controls, delta)
		pass

	if controls.dev_menu:
		DevMenu.Toggle()

	if controls_gamepad.direction_y != 0 or controls_gamepad.direction_x != 0:
		gamepad = true
		gamepad_countdown = 10

	if gamepad_countdown > 0:
		gamepad_countdown -= delta
	else:
		gamepad = false

	if gamepad == true:
		$Sprite2D/KnifeSprite.look_at(self.position + Vector2(controls_gamepad.direction_x * 100, controls_gamepad.direction_y * 100))
		$Sprite2D/ArrowSprite.look_at(self.position + Vector2(controls_gamepad.direction_x * 100, controls_gamepad.direction_y * 100))
	else:
		$Sprite2D/KnifeSprite.look_at(get_global_mouse_position())
		$Sprite2D/ArrowSprite.look_at(get_global_mouse_position())
		
	if(controls.attack):
		if cooldown <= 0:
			attack()
	if(controls.alt_attack):
		if alt_cooldown <=0:
			alt_attack()

func shoot_knife(_direction):
	var knife = preload("res://assets/scenes/knifeProjectile.tscn").instantiate()
	knife.position = self.position
	knife.apply_impulse(Vector2.RIGHT.rotated($Sprite2D/KnifeSprite.rotation+_direction)*projectileSpeed)
	knife.rotation = $Sprite2D/KnifeSprite.rotation+_direction
	get_tree().get_root().get_node(".").add_child(knife)
func alt_attack():
	if(!canAttack):
		return
	alt_cooldown = 1 / ((attackSpeed)*2 -1) * 2
	$Control/TextureProgressBar.value=alt_cooldown
	match Global.Player_temp_data["powerups"]["multishot"]:
		1:
			shoot_knife(0)
		3:
			shoot_knife(-PI/12)
			shoot_knife(0)
			shoot_knife(PI/12)
		5:
			shoot_knife(-PI/6)
			shoot_knife(-PI/12)
			shoot_knife(0)
			shoot_knife(PI/12)
			shoot_knife(PI/6)
	
func attack():
	if(!canAttack):
		return
	cooldown = 1 / attackSpeed
	$Sprite2D/KnifeSprite.visible = true
	$Sprite2D/KnifeAnimation.play("attack")
	await $Sprite2D/KnifeAnimation.animation_finished

	for enemy in $Sprite2D/KnifeSprite/Area2D.get_overlapping_areas():
		var knockbackVector = Vector2.RIGHT.rotated($Sprite2D/KnifeSprite.rotation)
		var attackpower = Global.Player_temp_data["attack_power"]
		var Damage = rng.randi_range(attackpower-5,attackpower+5)
		enemy.get_parent().receiveDamage(Damage,knockbackVector)
		if Global.Player_temp_data["powerups"]["bleeding"] > 0:
			enemy.get_parent()._bleed(Global.Player_temp_data["powerups"]["bleeding"],Damage*2/Global.Player_temp_data["powerups"]["bleeding"])

	$Sprite2D/KnifeAnimation.play_backwards("attack")
	await $Sprite2D/KnifeAnimation.animation_finished
	$Sprite2D/KnifeSprite.visible = false


func normal_movement(controls : Dictionary):
	velocity = Vector2.ZERO
	if controls.move_right:
		velocity.x += 1
		if !controls.move_down and !controls.move_up:
			$Sprite2D/AnimationPlayer.play("walk_right")

	if controls.move_left:
		velocity.x -= 1
		if !controls.move_down and !controls.move_up:
			$Sprite2D/AnimationPlayer.play("walk_left")

	if controls.move_down:
		velocity.y += 1
		$Sprite2D/AnimationPlayer.play("walk_down")

	if controls.move_up:
		velocity.y -= 1
		$Sprite2D/AnimationPlayer.play("walk_up")


	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	else:
		$Sprite2D/AnimationPlayer.stop()

func boss_movement(controls : Dictionary, delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	if controls.move_up and is_on_floor():
		velocity.y = jump_velocity
	if controls.move_right:
		velocity.x = 1 * speed
		$Sprite2D.flip_h = false
		$Sprite2D/AnimationPlayer.play("walk_right")
	elif controls.move_left:
		velocity.x = -1 * speed
		$Sprite2D.flip_h = true
		$Sprite2D/AnimationPlayer.play("walk_right")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		$Sprite2D/AnimationPlayer.stop()

func _physics_process(_delta):
	move_and_slide()

func on_door_enter(direction, targetScene):
	freeze = true
	force = direction
	$Sprite2D/DoorAnimation.play("smoll")
	await $Sprite2D/DoorAnimation.animation_finished
	SceneTransition.change_scene_packed(targetScene)

func _player_toggle_noclip(noclip : bool):
	freeze = false
	if noclip:
		set_collision_layer_value(1, false)
		set_collision_mask_value(2, false)
		set_collision_mask_value(3, false)
		set_collision_mask_value(4, false)
	else:
		set_collision_layer_value(1, true)
		set_collision_mask_value(2, true)
		set_collision_mask_value(3, true)
		set_collision_mask_value(4, true)

func _kill_player():
	if !freeze:
		$DeathSound.play()
		freeze = true
		canAttack = false
		$Sprite2D.modulate	= Color(1, 0.4, 0.4)
		await get_tree().create_timer(1).timeout
		queue_free()

func _player_damage(_number):
	if !freeze:
		$HurtSound.play()
		$Sprite2D.modulate	= Color(1, 0.4, 0.4)
		await get_tree().create_timer(0.4).timeout
		$Sprite2D.modulate	= Color(1, 1, 1)

func _on_item_pickup_area_entered(area):
	var itemToAdd:Item = area.get_parent().itemToAdd
	Global.add_item.emit(itemToAdd)
	area.get_parent().queue_free()

func _on_item_magnet_area_entered(area):
	area.get_parent().isMagnetized = true
	area.get_parent().objectToLookAt = self

func _on_item_magnet_area_exited(area):
	area.get_parent().isMagnetized = false

func _refreshStats():
	attackSpeed = Global.Player_temp_data["attack_speed"]
	speed = Global.Player_temp_data["movement_speed"]


func _on_player_detector_area_entered(area):
	var direction = area.get_parent().get_meta("direction")
	on_door_enter(direction,area.get_meta("Scene"))
	
