extends KinematicBody2D

export var gravity = 10
export var walk_speed = 25
var movement = Vector2(walk_speed, 0)
#variaveis da movimentacao
var react_time = 100
var direction = 0
var next_direction = 0
var next_direction_time = 0
#fim da movimentacao
var last_animation = ""

onready var player = get_parent().get_node("Haytham")

var life = 0.5
var strength = 1
var attack = 1
var defense = 1
var is_dead = false
var acabou = false
func _ready():
	
	$AnimatedSprite.play("walk")

func _physics_process(delta):
	if is_dead :
		
		$AnimatedSprite.play("death")
		
		last_animation = "death"
		
		if not is_death():
			queue_free()
	if life <= 0:
		
		is_dead = true
		$DetectedPlayer/Detected.disabled = true
		$AttackSkeleton.monitoring = false
		$CollisionShape2D.disabled = true
		
		movement.x = 0
		
	if player.life <=0:
		#desativa o ataque do esqueleto
		$AttackSkeleton.monitoring = false
		
	if not is_dead:
		if player.position.x < position.x and next_direction != -1:
			next_direction = -1
			$AnimatedSprite.scale.x=-1
			$AttackSkeleton/Attack.scale.x = -1
			$AttackSkeleton/Attack.position.x = -12
			$DetectedPlayer/Detected.scale.x = -1
			$DetectedPlayer/Detected.position.x = -14.085
			next_direction_time = OS.get_ticks_msec()+react_time
		elif player.position.x > position.x and next_direction != 1:
			next_direction = 1
			$AnimatedSprite.scale.x=1
			$AttackSkeleton/Attack.scale.x = 1
			$AttackSkeleton/Attack.position.x = 12
			$DetectedPlayer/Detected.scale.x = 1
			$DetectedPlayer/Detected.position.x = 14.085
			next_direction_time = OS.get_ticks_msec()+react_time
	if not is_dead:
		if OS.get_ticks_msec() > next_direction_time:
			direction = next_direction
	if not is_dead:
		movement.x = direction*walk_speed
		move_and_slide_with_snap(movement, Vector2(0,2), Vector2.UP, true, 4, 0.9)
	
	
	update_animations()

func update_animations():

			
			
	if  not is_attacking() and not is_death():
		$AnimatedSprite.play("walk")

func _on_DetectedPlayer_body_entered(body):
	if(body.get_name() == "Haytham"):
		if not is_dead:
			$AnimatedSprite.play("attack")
			$Death_sound.play()
			last_animation = "attack"
			$Animation_time.start()
			

func is_attacking():
	
	return last_animation == "attack" and $AnimatedSprite.frame!=7
func is_death():
	return last_animation == "death" and $AnimatedSprite.frame!=4
func _on_Timer_timeout():
	
	$AttackSkeleton.monitoring = false

func _on_AttackSkeleton_body_entered(body):
	print(body.life)
	player.life -=1
	#if player.position.x < position.x:
	#	player.position.x -= 30
	#	player.position.y -= 10
	#else:
	#	player.position.x += 30
	#	player.position.y -= 10
	print(player.life)

func _on_Animation_time_timeout():
	$DetectedPlayer/Timer.start()
	$AttackSkeleton.monitoring = true
	

func take_damage(attack_style):
	if attack_style == "slash":
		var damage = 0.5 * (  player.strength)
		life -= damage
		print(life)
	else:
		pass
	
	if life <= 0:
		print("dead")
		

func _on_delay_timeout():
	queue_free()
	pass # Replace with function body.
