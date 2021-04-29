extends Node

func swordAtributes(sword, attack_style):
	if sword == "Steel_longsword":
		if attack_style == "slash":
			return 5
		else:
			return 10
	if sword == "Chaos_longsword":
		if attack_style == "slash":
			return 20
		else:
			return 40
