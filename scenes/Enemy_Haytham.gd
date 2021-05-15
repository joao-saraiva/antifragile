extends KinematicBody2D

export var gravity = 10
export var walk_speed = 60
var canAttack = false
var is_dead = false
var life = 0.1
var react_time = 200
var direction = 0
var next_direction = 0
var next_direction_time = 0
var movement = Vector2(0, 0)
var last_animation = " "
var arrow_direction = Vector2(0,0)
var canFollow = false
var strengh = 1
var push_power = 15
var defence = 3
var attacking = false

onready var player = get_parent().get_node("Haytham")
onready var arrow = preload("res://scenes/FLEXA.tscn")
var contador = 0

func _ready():
	$AnimatedSprite.play("walk")
	last_animation = "walk"
func _physics_process(delta):
	if is_on_ceiling():
		movement.y = 0
	if !is_on_floor():
		movement.y+= gravity
	else:
		movement.y = gravity
		
	if life <=0 :
		is_dead = true
	if canAttack:
		$AnimatedSprite.play("attack")
		last_animation = "attack"
		$Attack.monitoring = true
		attacking = true
		next_direction = 0
	if last_animation == "attack" and $AnimatedSprite.frame == 2:
		attacking = false
		$Attack.monitoring = false
		canAttack = false
		$Timer.start()
	if is_dead:
		$AnimatedSprite.play("death")
		last_animation = "death"
		next_direction = 0
		
		
	if last_animation == "death" and $AnimatedSprite.frame == 11:
		queue_free()
	if canFollow and not attacking:
		if player.position.x < position.x and next_direction != -1:
				next_direction = -1
				$AnimatedSprite.scale.x=-0.13
				$CanAttack/CollisionShape2D.position.x = -14.936
				$Attack/CollisionShape2D.position.x = -14.716
				next_direction_time = OS.get_ticks_msec()+react_time
				push_power *= -1
		elif player.position.x > position.x and next_direction != 1:
				next_direction = 1
				$AnimatedSprite.scale.x=0.13
				$CanAttack/CollisionShape2D.position.x = 14.936
				$Attack/CollisionShape2D.position.x = 14.716
				push_power *= -1
				next_direction_time = OS.get_ticks_msec()+react_time
	if not is_dead:
		if OS.get_ticks_msec() > next_direction_time:
			direction = next_direction
	if not is_dead:
		movement.x = direction*walk_speed
		move_and_slide_with_snap(movement, Vector2(0,2), Vector2.UP, true, 4, 0.9)
	update_animations()
	
func update_animations():
	if not attacking and not is_dead:
		$AnimatedSprite.play("walk")
		last_animation = "walk"
		

func take_damage():
	print(life)
	if player.attack_style == "slash":
		var damage = (3*Swords.swordAtributes(player.sword,player.attack_style)+3*player.strength*player.chaos_multiplier)/defence
		life -= damage
	else:
		var damage = 0.5 * (3*Swords.swordAtributes(player.sword,player.attack_style)+3*player.strength*player.chaos_multiplier)/defence
		life -= damage
	if life <= 0:
		player.experience += 1100
		if player.chaos + 50 > 100:
			player.chaos = 100
		else:
			player.chaos += 50


func _on_CanFollow_body_entered(body):
	if body.get_name() == "Haytham":
		canFollow = true
	pass # Replace with function body.


func _on_CanAttack_body_entered(body):
	if body.get_name() =="Haytham":
		canAttack = true
	pass # Replace with function body.


func _on_CanAttack_body_exited(body):
	if body.get_name() =="Haytham":
		canAttack = false
	
	pass # Replace with function body.


func _on_Attack_body_entered(body):\
	if body.get_name() =="Haytham":
		print("entramos aqui")
		player.take_damage(position,strengh,push_power)


func _on_Timer_timeout():
	canAttack = true
	pass # Replace with function body.
