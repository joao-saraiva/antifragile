extends Node2D

signal pickup(item, node)

func _ready():
	$AnimationPlayer.play("New Anim")

func _on_life_potion_body_entered(body):
	emit_signal("pickup", "life_potion", self)
