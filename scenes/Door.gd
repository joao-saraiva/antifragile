extends StaticBody2D

onready var player = get_tree().root.get_node("Inferno").get_node("Haytham")
var inside = false

func _process(delta):
	if inside:
		if Input.is_action_just_pressed("attack") and player.sword == "key":
			queue_free()
	
func _on_Area2D_body_entered(body):
	inside = true

func _on_Area2D_body_exited(body):
	inside = false
