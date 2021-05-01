extends KinematicBody2D

var strength = 40
var push_power = 15
var next_direction = 0
var movement = Vector2(0,0)
var onAir = true

func _ready():
	pass 


func _process(delta):
	
	movement.x = -30
	move_and_collide(Vector2(movement.x,0))
	

	pass
