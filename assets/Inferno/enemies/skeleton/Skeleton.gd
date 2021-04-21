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
	if not is_attacking():
		$AnimatedSprite.play("walk")
	last_animation = $AnimatedSprite.animation
func _physics_process(delta):
	
	
	
	if player.position.x < position.x and next_direction != -1:
		next_direction = -1
		$AnimatedSprite.scale.x=-1
		$AttackSkeleton/Attack.scale.x = -1
		$AttackSkeleton/Attack.position.x = -12.929
		$DetectedPlayer/Detected.scale.x = -1
		$DetectedPlayer/Detected.position.x = -24.975
		next_direction_time = OS.get_ticks_msec()+react_time
		
		
		
	elif player.position.x > position.x and next_direction != 1:
		next_direction = 1
		$AnimatedSprite.scale.x=1
		$AttackSkeleton/Attack.scale.x = 1
		$AttackSkeleton/Attack.position.x = 12.929
		$DetectedPlayer/Detected.scale.x = 1
		$DetectedPlayer/Detected.position.x = 24.975
		next_direction_time = OS.get_ticks_msec()+react_time
		
		
		
	
	
	if OS.get_ticks_msec() > next_direction_time:
		direction = next_direction
		
	
	movement.x = direction*walk_speed
	
	
	
	move_and_slide_with_snap(movement, Vector2(0,2), Vector2.UP, true, 4, 0.9)
	
	
	

func is_attacking():
	return last_animation == "attack" and $AnimatedSprite.frame !=5
	pass




func _on_DetectedPlayer_body_entered(body):
	if(body.get_name() == "Haytham"):
		$AnimatedSprite.play("attack")
		
		
		$DetectedPlayer/Timer.start()
		$AttackSkeleton.monitoring = true
		


	

func _on_Timer_timeout():
	$AttackSkeleton.monitoring = false
	
	pass # Replace with function body.


func _on_AttackSkeleton_body_entered(body):
	player.life -=1
	if player.position.x < position.x:
		player.position.x -= 30
	else:
		player.position.x += 30
	print(player.life) 
	pass # Replace with function body.
