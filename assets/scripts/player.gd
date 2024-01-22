extends CharacterBody2D

@export var speed = 400 # How fast the player will move (pixels/sec).
@export var jump_velocity = -500
@export var gravity = 900
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


func _ready():
	screen_size = get_viewport_rect().size
	Global.set_scene(get_parent().name)
	DevMenu.Ui_update()
	DevMenu.Player_toggle_noclip.connect(_player_toggle_noclip)
	Global.player_died.connect(_kill_player)
	Global.player_damage.connect(_player_damage)

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
	else:
		$Sprite2D/KnifeSprite.look_at(get_global_mouse_position())

	#Nie wiem czy nie mozna tego wruzcic do ifa z normal_movement()
	#ale potrzebujemy pierwszeństwo do atakowania góra i dół bo jak idziemy po ukosie to patrzymy sie w góre lub w dół
	if(controls.move_up):
		facingDirectionVector = Vector2(0, -1)
	elif(controls.move_down):
		facingDirectionVector = Vector2(0, 1)
	elif(controls.move_left):
		facingDirectionVector = Vector2(-1, 0)
	elif(controls.move_right):
		facingDirectionVector = Vector2(1, 0)
	if(controls.attack):
		if cooldown <= 0:
			attack()
	if(controls.alt_attack):
		if alt_cooldown <=0:
			alt_attack()
		
func alt_attack():
	alt_cooldown = 2
	$Control/TextureProgressBar.value=alt_cooldown
	var knife = preload("res://assets/scenes/knifeProjectile.tscn").instantiate()
	knife.position = self.position
	knife.apply_impulse(Vector2.RIGHT.rotated($Sprite2D/KnifeSprite.rotation)*projectileSpeed)
	knife.rotation = $Sprite2D/KnifeSprite.rotation
	get_tree().get_root().get_node(".").add_child(knife)
func attack():
	cooldown = 1 / attackSpeed
	$Sprite2D/KnifeSprite.visible = true
	$Sprite2D/KnifeAnimation.play("attack")
	await $Sprite2D/KnifeAnimation.animation_finished

	for enemy in $Sprite2D/KnifeSprite/Area2D.get_overlapping_areas():
		var knockbackVector = Vector2.RIGHT.rotated($Sprite2D/KnifeSprite.rotation)
		enemy.get_parent().receiveDamage(10,knockbackVector)

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
	SceneTransition.change_scene(targetScene)
	print("ok")

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
	queue_free()

func _player_damage(_number):
	$Sprite2D.modulate	= Color(1, 0.4, 0.4)
	await get_tree().create_timer(0.4).timeout
	$Sprite2D.modulate	= Color(1, 1, 1)
