extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/StartButton.grab_focus()



func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://assets/scenes/lobby.tscn")


func _on_options_button_pressed():
	#to z poradnika wklejone, chuj wie czy bedziemy tak robic
	#var options = load("res do sceny").instance()
	#get_tree().current_scene.add_child(options)
	pass #zeby funkcja nie waliła errora ze jest pusta 


func _on_quit_button_pressed():
	get_tree().quit()
