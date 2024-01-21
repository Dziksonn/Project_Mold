extends Area2D

@export_file("*.tscn") var targetScene: String

func _ready():
	var player = owner.get_node("Player/PlayerDetector")
	player.area_entered.connect(_on_player_detector_area_entered)

func _on_player_detector_area_entered(area):
	print("test")
	var direction = area.get_meta("direction")
	trigger_player_door_func(direction)

func trigger_player_door_func(direction):
	var player = owner.get_node("Player")
	player.on_door_enter(direction, targetScene)

