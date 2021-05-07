extends Node2D

signal pickup(item, node)

func _ready():
	$AnimationPlayer.play("New Anim")

func _on_key_body_entered(body):
	emit_signal("pickup", "key", self)
