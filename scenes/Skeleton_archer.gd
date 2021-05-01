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
var strengh = 40
var push_power = 15
onready var player = get_parent().get_node("Haytham")
onready var arrow = preload("res://scenes/FLEXA.tscn")

func _ready():
	$AnimatedSprite.play("waiting")
	
	pass 

func _process(delta):

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
		elif player.position.x > position.x and next_direction != 1:
			next_direction = 1
			$AnimatedSprite.scale.x = 1
			$CanAttack/CollisionShape2D.scale.x = 1
			$CanAttack/CollisionShape2D.position.x = 195
			arrow_direction = Vector2.RIGHT
		pass
	if canAttack:
		$AnimatedSprite.play("attack")
		last_animation = "attack"
		
	if last_animation == "attack" and $AnimatedSprite.frame == 2 :
		canArrow = true
		pass
	if canArrow:
			canArrow = false
			$attackSound.play()
			var a = arrow.instance()
			add_child(a)
			a.direction = arrow_direction
			a.escala = next_direction
			if a.hitHaytham == true:
				player.take_damage(position,strengh,push_power)



func _on_CanAttack_body_entered(body):
	canAttack = true
	
	
	pass # Replace with function body.


func _on_CanAttack_body_exited(body):
	$AnimatedSprite.play("waiting")
	last_animation = "waiting"
	canAttack = false
	pass # Replace with function body.
