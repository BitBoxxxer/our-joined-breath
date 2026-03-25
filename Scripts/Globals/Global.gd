extends Node

func interact(inter_node: String) -> void:
	match inter_node:
		"Monitor":
			print("Открыли монитор !")
			get_tree().change_scene_to_file("res://Scenes/HUD/Obj_Items/Main_Monitor.tscn")
		_:
			print("Непонятная херня, не записал что это и как это работает :))")
