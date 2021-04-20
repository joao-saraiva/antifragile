extends KinematicBody2D

export var gravity = 10
export var walk_speed = 120
export var jump_speed = -300
export var movement = Vector2(0,0)

func _physics_process(delta):
	if is_on_ceiling():
		movement.y = 0
	if !is_on_floor():
		movement.y+= gravity
	else:
		movement.y = gravity
		
	var horizontal_axis = Input.get_action_strength("right")-Input.get_action_strength("left")
	
	movement.x = horizontal_axis*walk_speed
	if Input.is_action_just_pressed("jump") and is_on_floor():
		movement.y = jump_speed
	
	move_and_slide_with_snap(movement, Vector2(0,2), Vector2.UP, true, 4, 0.9)
	update_animations()
	
func update_animations():
	if movement.x>0 :
		$AnimatedSprite.scale.x = 1
	elif movement.x<0:
		$AnimatedSprite.scale.x = -1
		
	if is_on_floor():
		if abs(movement.x)>0:
			$AnimatedSprite.play("walking")
		else:
			$AnimatedSprite.play("idle")
	else:
		$AnimatedSprite.play("jump")

