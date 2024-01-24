extends Node2D


func _ready():
    Global.set_scene(name)
    $AnimationPlayer.play("fade")
    await get_tree().create_timer(3).timeout
    SceneTransition.change_scene("res://assets/scenes/lobby.tscn")

