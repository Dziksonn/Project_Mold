extends CharacterBody2D

@export var max_health = 200
var health = max_health

@export var speed = 360
@export var accel = 7
@export var attack_player = false
@export var damage = 1

@onready var nav : NavigationAgent2D = $NavigationAgent2D
@onready var player : CharacterBody2D = owner.get_node("Player")

var knockbacked : bool = false
var knock_direction_physics : Vector2 = Vector2()

func _ready():
	$HealthBar.max_value = max_health
	$HealthBar.value = health
	set_physics_process(false)
	await get_tree().physics_frame
	set_physics_process(true)
	get_node("Hitbox").body_entered.connect(OnBodyEntered)
	get_node("Hitbox").body_exited.connect(OnBodyExited)

func receiveDamage(amount, knock_direction : Vector2):
	health -= amount
	$HealthBar.value = health
	knockback(knock_direction)
	if health <= 0:
		$AnimationPlayer.play('ded')
		await $AnimationPlayer.animation_finished
		queue_free()
		Global.enemy_killed.emit()
		Global.coins_earned.emit(20)

func knockback(knok_direction):
	knock_direction_physics = knok_direction
	knockbacked = true
	await get_tree().create_timer(0.1).timeout
	knockbacked = false

func _physics_process(delta):
	var direction = Vector3()

	if is_instance_valid(player):

		nav.target_position = player.position

		direction = nav.get_next_path_position() - global_position
		direction = direction.normalized()
		if knockbacked:
			direction = knock_direction_physics * 10

		velocity = velocity.lerp(direction * speed, accel * delta)

		move_and_slide()


func OnBodyEntered(body):
	if (body.name == "Player"):
		attack_player = true
		while attack_player:
			Global.player_damage.emit(damage)
			await get_tree().create_timer(0.5).timeout

func OnBodyExited(body):
	if (body.name == "Player"):
		attack_player = false
