extends KinematicBody2D

export var gravity = 10
export var walk_speed = 40
var movement = Vector2(walk_speed, 0)

func _physics_process(delta):
	if !is_on_floor():
		movement.y+= gravity
	else:
		movement.y = gravity
	if is_on_wall():
		walk_speed *= -1
		$AnimatedSprite.scale.x *= -1
	
	movement.x = walk_speed
	move_and_slide_with_snap(movement, Vector2(0,2), Vector2.UP, true, 4, 0.9)
