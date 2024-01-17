extends Node

var actual_scene : String
var boss_fight : bool

func set_scene_name(scene_name):
	actual_scene = scene_name
	match actual_scene:
		"boss_scene":
			boss_fight = true
		"menu":
			boss_fight = true
		_: #default
			boss_fight = false


func _ready():
	pass
func _process(delta):
	pass
