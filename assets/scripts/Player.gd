extends CharacterBody2D

@export var speed = 400 # How fast the player will move (pixels/sec).
@export var boss_fight = false
var Velocity = Vector2()
var screen_size # Size of the game window.
var freeze = false
var force = "off"

func _ready():
	screen_size = get_viewport_rect().size
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT	
	
func _process(delta):
	velocity = Vector2.ZERO
	var move_right = Input.is_action_pressed("move_right")
	var move_left = Input.is_action_pressed("move_left")
	var move_down = Input.is_action_pressed("move_down")
	var move_up = Input.is_action_pressed("move_up")
	if freeze:
		move_right = false;
		move_left = false;
		move_down = false;
		move_up = false;
		
	if force != "off":
		match(force):
			"right":
				move_right = true
			"left":
				move_left = true
			"down":
				move_down = true
			"up":
				move_up = true
		
		
	if move_right:
		velocity.x += 1
	if move_left:
		velocity.x -= 1
	if move_down:
		velocity.y += 1
	if move_up:
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		#$AnimatedSprite2D.play("default")
	#else:
		#$AnimatedSprite2D.stop()
	
		
func _physics_process(delta):
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		#print("I collided with ", collision.get_collider().name)
		
func on_door_enter(direction):
	freeze = true
	force = direction
	$Sprite2D/AnimationPlayer.play("smoll")
	print("ok")
	
