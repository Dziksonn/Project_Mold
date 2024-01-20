extends CharacterBody2D

@export var speed = 400 # How fast the player will move (pixels/sec).
@export var jump_velocity = -500
@export var gravity = 900
var Velocity = Vector2()
var screen_size # Size of the game window.
var freeze = false
var force = "off"
var dev_ui
var canAttack = true
var attackSpeed = 1 # = 1 attack per seccond
var FacingDirection = "Down"

#Nie mam pomyslu jak to lepiej zrobić niż przechowujac liste przeciwnikow w zasiegu
var DownEnemies = Array()
var UpEnemies = Array()
var LeftEnemies = Array()
var RightEnemies = Array()

func _ready():
	screen_size = get_viewport_rect().size
	Global.set_scene(get_parent().name)
	DevMenu.Ui_update()
	DevMenu.Player_toggle_noclip.connect(_player_toggle_noclip)
	Global.player_died.connect(_kill_player)

func _process(delta):

	var controls = {
		move_right = Input.is_action_pressed("move_right"),
		move_left = Input.is_action_pressed("move_left"),
		move_down = Input.is_action_pressed("move_down"),
		move_up = Input.is_action_pressed("move_up"),
		dev_menu = Input.is_action_just_pressed("dev_menu"),
		attack = Input.is_action_just_pressed("attack")
	}
	if freeze:
		controls.move_right = false;
		controls.move_left = false;
		controls.move_down = false;
		controls.move_up = false;
		controls.attack = false;


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
		

	
	#Nie wiem czy nie mozna tego wruzcic do ifa z normal_movement() 
	#ale potrzebujemy pierwszeństwo do atakowania góra i dół bo jak idziemy po ukosie to patrzymy sie w góre lub w dół
	if(controls.move_up):
		FacingDirection = "Up"
	elif(controls.move_down):
		FacingDirection = "Down"
	elif(controls.move_left):
		FacingDirection = "Left"
	elif(controls.move_right):
		FacingDirection = "Right"
		
	if controls.attack:
		attack()

func attack():
	if(canAttack):
		if(FacingDirection == "Up"):
			print("UP")

func normal_movement(controls : Dictionary):
	velocity = Vector2.ZERO
	if controls.move_right:
		velocity.x += 1
		$Sprite2D.flip_h = false
		if !controls.move_down and !controls.move_up:
			$Sprite2D/AnimationPlayer.play("walk_right")
	if controls.move_left:
		velocity.x -= 1
		if !controls.move_down and !controls.move_up:
			$Sprite2D.flip_h = true
			$Sprite2D/AnimationPlayer.play("walk_right")
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

func _on_enemy_down_area_entered(area):
	print('down')
	if(area.get_meta("CollisionType") == "Enemy"):
		DownEnemies.push_front(area)


func _on_enemy_right_area_entered(area):
	print('right')
	if(area.get_meta("CollisionType") == "Enemy"):
		RightEnemies.push_front(area)


func _on_enemy_left_area_entered(area):
	print('left')
	if(area.get_meta("CollisionType") == "Enemy"):
		LeftEnemies.push_front(area)


func _on_enemy_up_area_entered(area):
	print('up')
	if(area.get_meta("CollisionType") == "Enemy"):
		UpEnemies.push_front(area)
