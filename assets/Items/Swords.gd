extends Node

func swordAtributes(sword, attack_style):
	if sword == "Steel_longsword":
		if attack_style == "slash":
			return 5
		else:
			return 10
	elif sword == "none":
		return 0
