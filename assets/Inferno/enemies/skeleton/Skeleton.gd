extends KinematicBody2D

export var gravity = 10
export var walk_speed = 60
var movement = Vector2(walk_speed, 0)
var react_time = 100
var direction = 0
var next_direction = 0
var next_direction_time = 0
onready var player = get_parent().get_node("Haytham")

func _physics_process(delta):
	if player.position.x < position.x and next_direction != -1:
		next_direction = -1
		$AnimatedSprite.scale.x*=-1
		next_direction_time = OS.get_ticks_msec()+react_time
		
		
		
	elif player.position.x > position.x and next_direction != 1:
		next_direction = 1
		$AnimatedSprite.scale.x*=-1
		next_direction_time = OS.get_ticks_msec()+react_time
		
		
		
	
	
	if OS.get_ticks_msec() > next_direction_time:
		direction = next_direction
		
	
	movement.x = direction*walk_speed
	
	
	
	move_and_slide_with_snap(movement, Vector2(0,2), Vector2.UP, true, 4, 0.9)
	
	
	
