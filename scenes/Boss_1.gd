extends KinematicBody2D


export var gravity = 10
export var walk_speed = 25
var movement = Vector2(walk_speed, 0)
#variaveis da movimentacao
var react_time = 200
var direction = 0
var next_direction = 0
var next_direction_time = 0
#fim da movimentacao
var last_animation = ""
var player_detected = false
var canFollow = false
onready var player = get_parent().get_node("Haytham")

var life = 0.5
var strength = 1000
var attack = 1
var defense = 1
var is_dead = false
var push_power = 150

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	$Boss_animated_sprite.play("walk")
	pass # Replace with function body.

func _process(delta):
	if life <= 0:
		is_dead = true
	if is_dead:
		movement.x = 0
		$Boss_animated_sprite.play("death")
		last_animation = "death"
		
		
	if last_animation == "attack" and $Boss_animated_sprite.frame == 4:
		$Heavy_attack.play()
	if last_animation == "attack" and $Boss_animated_sprite.frame == 8:
		#print("ataque up")
		$CanAttack.monitoring = true
		$Attack.monitoring = false
	if last_animation == "attack" and $Boss_animated_sprite.frame == 5:
		$Attack.monitoring = true
	if last_animation == "death" and $Boss_animated_sprite.frame == 2:
		$Boss_animated_sprite.stop()
		
	if is_on_ceiling():
		movement.y = 0
	if !is_on_floor():
		movement.y+= gravity
	else:
		movement.y = gravity
	

	
	if canFollow and not is_attacking() and not is_dead:
		#print(position.x)
		$CanFollow.monitoring = false
		if player.position.x < position.x and next_direction != -1:
			next_direction = -1
			$Boss_animated_sprite.scale.x =-1
			$CanAttack/CanAttackShape.scale.x = -1
			$CanAttack/CanAttackShape.position.x = -26.751
			$Attack/AttackShape.scale.x = -1
			$Attack/AttackShape.position.x = -26.751
			push_power = -30
			next_direction_time = OS.get_ticks_msec()+react_time
		elif player.position.x > position.x and next_direction != 1:
			next_direction = 1
			$Boss_animated_sprite.scale.x =1
			$CanAttack/CanAttackShape.scale.x = 1
			$CanAttack/CanAttackShape.position.x = 26.751
			$Attack/AttackShape.scale.x = 1
			$Attack/AttackShape.position.x = 26.751
			push_power = 30
			next_direction_time = OS.get_ticks_msec()+react_time
	if not is_dead:
		if OS.get_ticks_msec() > next_direction_time:
			direction = next_direction
			movement.x = direction*walk_speed
			move_and_slide_with_snap(movement, Vector2(0,2), Vector2.UP, true, 4, 0.9)
			update_animations()
	


func update_animations():
	if not is_attacking() and not is_dead:
		$Boss_animated_sprite.play("walk")
	pass
func is_attacking():
	return last_animation == "attack" and $Boss_animated_sprite.frame !=8
func is_dead():
	return last_animation == "death" and $Boss_animated_sprite.frame!=2
func _on_CanFollow_body_entered(body):
	if body.get_name() == "Haytham":
		canFollow = true
		#print("entrou")
	

func attack():
	$Boss_animated_sprite.play("attack")
	last_animation = "attack"
	$CanAttack.monitoring = false
	$CanAttackTime.start()

func _on_CanAttack_body_entered(body):
	if body.get_name() == "Haytham" and not is_dead:
		attack()
		
func take_damage():
	
	if player.attack_style == "slash":
		var damage = 0.5 * (Swords.swordAtributes(player.sword,player.attack_style)+player.strength)
		life -= damage
	else:
		var damage = 0.1 * (Swords.swordAtributes(player.sword,player.attack_style)+player.strength)
		life -= damage
	


func _on_Attack_body_entered(body):
	
	if body.get_name() == "Haytham":
		
		
		player.take_damage(position,strength,push_power)
		
	pass # Replace with function body.
