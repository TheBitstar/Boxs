extends Node2D

func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	pass

func _on_play_pressed() -> void:
	print("start")
	get_tree().change_scene_to_file("res://node_3d.tscn")
	
func _on_exit_pressed() -> void:
	print("exit")
	get_tree().quit()

func _on_back_pressed() -> void:
	print("back")
	get_tree().change_scene_to_file("res://main menu.tscn")
#made by TheBitstarDev on github.com
