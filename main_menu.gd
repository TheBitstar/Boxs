extends Control

func _ready() -> void:
	pass 

func _on_start_pressed() -> void:
	print("start")
	get_tree().change_scene_to_file("res://node_3d.tscn")

func _on_exit_pressed() -> void:
	print("exit")
	get_tree().quit()

func _on_how_to_play_pressed() -> void:
	print("how_to_play")
	get_tree().change_scene_to_file("res://how_to_play.tscn")
#made by TheBitstarDev on github.com
