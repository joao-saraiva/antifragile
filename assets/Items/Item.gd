extends Node2D
var item_name = "None"

func define_item(item):
	if item == "Chaos_longsword":
		$TextureRect.texture = load("res://assets/Items/Chaos_longsword.png")
		item_name = "Chaos_longsword"
	elif item == "testitem":
		$TextureRect.texture = load("res://assets/Items/testitem.png")
		item_name = "testitem"
	elif item == "life_potion":
		$TextureRect.texture = load("res://assets/Items/life_potion.png")
		item_name = "life_potion"
	elif item == "Steel_longsword":
		$TextureRect.texture = load("res://assets/Items/Steel_longsword.png")
		item_name = "Steel_longsword"
	elif item == "key":
		$TextureRect.texture = load("res://assets/Items/key.png")
		item_name = "key"
