extends Node2D

func _ready():
	if randi() % 2 == 0:
		$TextureRect.texture = load("res://assets/Items/Chaos_longsword.png")
	else:
		$TextureRect.texture = load("res://assets/Items/testitem.png")
