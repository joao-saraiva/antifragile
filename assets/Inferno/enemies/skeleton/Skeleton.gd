extends KinematicBody2D

export var gravity = 10
export var walk_speed = 60
var movement = Vector2(walk_speed, 0)
var react_time = 100
var direction = 0
var next_direction = 0
var next_direction_time = 0
var last_animation = ""
onready var player = get_parent().get_node("Haytham")

func _ready():
	
	$AnimatedSprite.play("walk")
	
	
func _physics_process(delta):
	
	
	
	if player.position.x < position.x and next_direction != -1:
		next_direction = -1
		$AnimatedSprite.scale.x=-1
		$AttackSkeleton/Attack.scale.x = -1
		$AttackSkeleton/Attack.position.x = -18.148
		$DetectedPlayer/Detected.scale.x = -1
		$DetectedPlayer/Detected.position.x = -14.085
		next_direction_time = OS.get_ticks_msec()+react_time
		
		
		
	elif player.position.x > position.x and next_direction != 1:
		next_direction = 1
		$AnimatedSprite.scale.x=1
		$AttackSkeleton/Attack.scale.x = 1
		$AttackSkeleton/Attack.position.x = 18.148
		$DetectedPlayer/Detected.scale.x = 1
		$DetectedPlayer/Detected.position.x = 14.085
		next_direction_time = OS.get_ticks_msec()+react_time
		
		
		
	
	
	if OS.get_ticks_msec() > next_direction_time:
		direction = next_direction
		
	
	movement.x = direction*walk_speed
	
	
	
	move_and_slide_with_snap(movement, Vector2(0,2), Vector2.UP, true, 4, 0.9)
	
	
	update_animations()

func update_animations():
	if  not last_animation:
		$AnimatedSprite.play("walk")
		
	
	


func _on_DetectedPlayer_body_entered(body):
	if(body.get_name() == "Haytham"):
		$AnimatedSprite.play("attack")
		
		last_animation = "attack" and $AnimatedSprite.frame!=5
		$Animation_time.start()
		
		
		
		


	

func _on_Timer_timeout():
	
	$AttackSkeleton.monitoring = false
	
	pass # Replace with function body.


func _on_AttackSkeleton_body_entered(body):
	player.life -=1
	if player.position.x < position.x:
		player.position.x -= 30
		player.position.y -= 10
	else:
		player.position.x += 30
		player.position.y -= 10
	print(player.life) 
	pass # Replace with function body.


func _on_Animation_time_timeout():
	$DetectedPlayer/Timer.start()
	$AttackSkeleton.monitoring = true
	last_animation= false
	
	pass # Replace with function body.
