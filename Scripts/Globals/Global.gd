extends Node

func interact(inter_node: String) -> void:
	match inter_node:
		"Npc":
			print("Talk ?")
		_:
			print("Global.gd: IDK")
