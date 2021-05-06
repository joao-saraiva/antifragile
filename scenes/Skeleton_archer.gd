extends KinematicBody2D

export var gravity = 10
var canAttack = false
var is_dead = false
var life = 0.5
var react_time = 200
var direction = 0
var next_direction = 0
var next_direction_time = 0
var movement = Vector2(0, 0)
var last_animation = " "
var arrow_direction = Vector2(0,0)
var canArrow = false
var strengh = 5
var push_power = 15
var defence = 3
var canArrow2 = true
onready var player = get_parent().get_node("Haytham")
onready var arrow = preload("res://scenes/FLEXA.tscn")
var contador = 0

func _ready():
	$AnimatedSprite.play("waiting")
	
	pass 

func _process(delta):
	if life <= 0 :
		queue_free()
	if is_on_ceiling():
		movement.y = 0
	if !is_on_floor():
		movement.y+= gravity
	else:
		movement.y = gravity
	move_and_collide(Vector2(0,movement.y))
	if  not is_dead:
		if player.position.x < position.x and next_direction != -1:
			next_direction = -1
			$AnimatedSprite.scale.x = -1
			$CanAttack/CollisionShape2D.scale.x = -1
			$CanAttack/CollisionShape2D.position.x = -195
			arrow_direction = Vector2.LEFT
			push_power *= -1
		elif player.position.x > position.x and next_direction != 1:
			next_direction = 1
			$AnimatedSprite.scale.x = 1
			$CanAttack/CollisionShape2D.scale.x = 1
			$CanAttack/CollisionShape2D.position.x = 195
			arrow_direction = Vector2.RIGHT
			push_power *= -1
		pass
	if canAttack:
		$AnimatedSprite.play("attack")
		last_animation = "attack"
	if last_animation == "attack" and $AnimatedSprite.frame == 6:
		canArrow2 = true
	if last_animation == "attack" and $AnimatedSprite.frame == 2 :
		
		
		if canArrow2:
			canArrow = true
			
	if canArrow:
			canArrow = false
			canArrow2 = false
			$attackSound.play()
			var a = arrow.instance()
			add_child(a)
			a.direction = arrow_direction
			a.escala = next_direction
			a.flexa_push_power = push_power
			a.flexa_strengh = strengh
			
			

func take_damage():
	
	if player.attack_style == "slash":
		var damage = (3*Swords.swordAtributes(player.sword,player.attack_style)+3*player.strength*player.chaos_multiplier)/defence
		life -= damage
	else:
		var damage = 0.5 * (3*Swords.swordAtributes(player.sword,player.attack_style)+3*player.strength*player.chaos_multiplier)/defence
		life -= damage
	if life <= 0:
		player.experience += 2
		if player.chaos + 50 > 100:
			player.chaos = 100
		else:
			player.chaos += 50


func _on_CanAttack_body_entered(body):
	if body.get_name() == "Haytham":
		canAttack = true
	
	
	pass # Replace with function body.


func _on_CanAttack_body_exited(body):
	if body.get_name() == "Haytham":
		$AnimatedSprite.play("waiting")
		last_animation = "waiting"
		canAttack = false
	pass # Replace with function body.
