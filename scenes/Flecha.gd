extends KinematicBody2D


var direction : Vector2 = Vector2.LEFT


#
func _ready():
	pass #


func _process(delta):
	move_and_slide(Vector2(direction))
	pass
	



func _on_Area2D_body_entered(body):
	if body.get_name() == "Skeleton_archer":
		$CollisionShape2D.disabled = true
	pass # Replace with function body.
