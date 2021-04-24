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
var player_detected = false

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
		if not is_dead():
			queue_free()
	
	if life <= 0:
		is_dead = true
		$DetectedPlayer/Detected.disabled = true
		$AttackSkeleton.monitoring = false
		$CollisionShape2D.disabled = true
		$Attack_sound.stop()
		movement.x = 0
		
	if player.life <=0:
		#desativa o ataque do esqueleto
		$AttackSkeleton.monitoring = false
		
	if not is_dead:
		if player_detected:
			if player.life > 0 and not is_dead and not is_attacking():
				$AnimatedSprite.play("attack")
				last_animation = "attack"
				$Attack_sound.play()
				$Animation_time.start()
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
	if  not is_attacking() and not is_dead():
		$AnimatedSprite.play("walk")
	last_animation = $AnimatedSprite.animation

func is_attacking():
	return last_animation == "attack" and $AnimatedSprite.frame!=7

func is_dead():
	return last_animation == "death" and $AnimatedSprite.frame!=4

func take_damage(attack_style):
	if attack_style == "slash":
		var damage = 0.5 * (  player.strength)
		life -= damage
	else:
		pass
	
	if life <= 0:
		$Death_sound.play()

func _on_DetectedPlayer_body_entered(body):
	if body.get_name() == "Haytham":
		player_detected = true

func _on_DetectedPlayer_body_exited(body):
	if body.get_name() == "Haytham":
		player_detected = false

func _on_Animation_time_timeout():
	$DetectedPlayer/Timer.start()
	print("on")
	$AttackSkeleton.monitoring = true

func _on_Timer_timeout():
	print("off")
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

func _on_delay_timeout():
	queue_free()
