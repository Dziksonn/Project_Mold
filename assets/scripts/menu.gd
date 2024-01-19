extends Area2D

#func _on_options_button_pressed():
	##to z poradnika wklejone, chuj wie czy bedziemy tak robic
	##var options = load("res do sceny").instance()
	##get_tree().current_scene.add_child(options)
	#pass #zeby funkcja nie waliła errora ze jest pusta

var button_names = ["start_button", "options_button", "exit_button"]

func _on_player_detector_area_entered(area):
	if button_names.has(area.name):
		area.get_node("Sprite2D").frame += 1
	match area.name:
		"start_trigger":
			# get_tree().change_scene_to_file("res://assets/scenes/lobby.tscn")
			SceneTransition.change_scene("res://assets/scenes/lobby.tscn")
		"options_trigger":
			print("Not ready")
		"exit_trigger":
			get_tree().quit()

func _on_player_detector_area_exited(area):
	if button_names.has(area.name):
		area.get_node("Sprite2D").frame -= 1
