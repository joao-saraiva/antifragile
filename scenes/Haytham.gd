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
		
	move_and_slide(movement,Vector2.UP)
	update_animations()
	
func update_animations():
	if movement.x>0 :
		$AnimatedSprite.scale.x = 2
	elif movement.x<0:
		$AnimatedSprite.scale.x = -2
		
		
		if is_on_floor():
			if abs(movement.x)>0:
				$AnimatedSprite.play("walking")
			else:
				$AnimatedSprite.play("idle")
		else:
			$AnimatedSprite.play("jump")
			
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
