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
var facingDirectionArray : Array
var facingDirectionVector : Vector2

#Nie mam pomyslu jak to lepiej zrobić niż przechowujac liste przeciwnikow w zasiegu
var downEnemies = Array()
var upEnemies = Array()
var leftEnemies = Array()
var rightEnemies = Array()

func _ready():
	screen_size = get_viewport_rect().size
	Global.set_scene(get_parent().name)
	DevMenu.Ui_update()
	DevMenu.Player_toggle_noclip.connect(_player_toggle_noclip)
	Global.player_died.connect(_kill_player)
	Global.player_damage.connect(_player_damage)

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

	#Nie wiem czy nie mozna tego wruzcic do ifa z normal_movement()
	#ale potrzebujemy pierwszeństwo do atakowania góra i dół bo jak idziemy po ukosie to patrzymy sie w góre lub w dół
	if(controls.move_up):
		facingDirectionArray = upEnemies
		facingDirectionVector = Vector2(0, -1)
	elif(controls.move_down):
		facingDirectionArray = downEnemies
		facingDirectionVector = Vector2(0, 1)
	elif(controls.move_left):
		facingDirectionVector = Vector2(-1, 0)
		facingDirectionArray = leftEnemies
	elif(controls.move_right):
		facingDirectionVector = Vector2(1, 0)
		facingDirectionArray = rightEnemies

	if controls.attack:
		attack()

func attack():
	if(canAttack):
		for enemy in facingDirectionArray:
			if enemy != null:
				enemy.get_parent().receiveDamage(10, facingDirectionVector)


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

func _player_damage(_number):
	$Sprite2D.modulate	= Color(1, 0.4, 0.4)
	await get_tree().create_timer(0.4).timeout
	$Sprite2D.modulate	= Color(1, 1, 1)

func _on_enemy_down_area_entered(area):
	downEnemies.push_front(area)


func _on_enemy_right_area_entered(area):
	rightEnemies.push_front(area)


func _on_enemy_left_area_entered(area):
	leftEnemies.push_front(area)


func _on_enemy_up_area_entered(area):
	upEnemies.push_front(area)


func _on_enemy_down_area_exited(area):
	downEnemies.remove_at(downEnemies.bsearch(area))


func _on_enemy_right_area_exited(area):
	rightEnemies.remove_at(rightEnemies.bsearch(area))


func _on_enemy_left_area_exited(area):
	leftEnemies.remove_at(leftEnemies.bsearch(area))


func _on_enemy_up_area_exited(area):
	upEnemies.remove_at(upEnemies.bsearch(area))
