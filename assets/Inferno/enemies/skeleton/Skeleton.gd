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
var strength = 100
var attack = 1
var defense = 1
var is_dead = false
var push_power = 5

func _ready():
	$AnimatedSprite.play("walk")

func _physics_process(delta):
	if is_on_ceiling():
		movement.y = 0
	if !is_on_floor():
		movement.y+= gravity
	else:
		movement.y = gravity
	
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
				$attack_on.start()
		if player.position.x < position.x and next_direction != -1:
			next_direction = -1
			$AnimatedSprite.scale.x=-1
			$AttackSkeleton/Attack.scale.x = -1
			$AttackSkeleton/Attack.position.x = -12
			$DetectedPlayer/Detected.scale.x = -1
			$DetectedPlayer/Detected.position.x = -32.685
			next_direction_time = OS.get_ticks_msec()+react_time
			push_power= -15
		elif player.position.x > position.x and next_direction != 1:
			next_direction = 1
			$AnimatedSprite.scale.x=1
			$AttackSkeleton/Attack.scale.x = 1
			$AttackSkeleton/Attack.position.x = 12
			$DetectedPlayer/Detected.scale.x = 1
			$DetectedPlayer/Detected.position.x = 32.685
			push_power= 15
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

func take_damage():
	$Death_sound.play()
	if player.attack_style == "slash":
		var damage = 0.5 * (Swords.swordAtributes(player.sword,player.attack_style)+player.strength)
		life -= damage
	else:
		var damage = 0.1 * (Swords.swordAtributes(player.sword,player.attack_style)+player.strength)
		life -= damage

func _on_DetectedPlayer_body_entered(body):
	if body.get_name() == "Haytham":
		player_detected = true

func _on_DetectedPlayer_body_exited(body):
	if body.get_name() == "Haytham":
		player_detected = false

func _on_attack_on_timeout():
	$DetectedPlayer/attack_off.start()
	$AttackSkeleton.monitoring = true

func _on_attack_off_timeout():
	$AttackSkeleton.monitoring = false

func _on_AttackSkeleton_body_entered(body):
	player.take_damage(position, strength,push_power)

func _on_delay_timeout():
	queue_free()
