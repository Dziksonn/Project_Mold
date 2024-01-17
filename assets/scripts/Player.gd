extends CharacterBody2D

@export var speed = 400 # How fast the player will move (pixels/sec).
@export var jump_velocity = -500
@export var gravity = 900
var Velocity = Vector2()
var screen_size # Size of the game window.
var freeze = false
var force = "off"
var dev_ui

func _ready():
	screen_size = get_viewport_rect().size
	Global.set_scene_name(get_parent().name)
	dev_ui = get_node("dev_ui")
	if is_instance_valid(dev_ui):
		if DevMenu.Status:
			dev_ui.visible = true
		else:
			dev_ui.visible = false
	
func _process(delta):
	var controls = {
		move_right = Input.is_action_pressed("move_right"),
		move_left = Input.is_action_pressed("move_left"),
		move_down = Input.is_action_pressed("move_down"),
		move_up = Input.is_action_pressed("move_up"),
	}
	if freeze:
		controls.move_right = false;
		controls.move_left = false;
		controls.move_down = false;
		controls.move_up = false;
		
	
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
	
		
func _physics_process(delta):
	move_and_slide()
		
func on_door_enter(direction):
	freeze = true
	force = direction
	#$Sprite2D/AnimationPlayer.play("smoll")
	print("ok")
	
