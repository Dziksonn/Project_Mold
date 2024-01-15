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
	normal_movement(controls)
		
func normal_movement(controls : Dictionary):
	velocity = Vector2.ZERO
	if controls.move_right:
		velocity.x += 1
		$Sprite2D.flip_h = false
		$Sprite2D/AnimationPlayer.play("walk_right")
	if controls.move_left:
		velocity.x -= 1
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
	
		
func _physics_process(delta):
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		#print("I collided with ", collision.get_collider().name)
		
func on_door_enter(direction):
	freeze = true
	force = direction
	#$Sprite2D/AnimationPlayer.play("smoll")
	print("ok")
	