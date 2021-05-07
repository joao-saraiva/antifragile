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
var attacking = false
var canFollow = false
var can_attack = false
var escolhido = false
var tocou = false
var is_hit = false
var onFuria = false
var attacking_furia = false
var timerAttack = true
onready var player = get_parent().get_node("Haytham")
var life = 150
var strength = 90
var defence = 70
var furia_strengh = 120
var furia_defense = 100
var is_dead = false
var push_power = 30
var push_power_fogo = 10
var rng = RandomNumberGenerator.new()

func _ready():
	$AnimatedSprite.play("walk")

func _process(delta):
	if life <= 100:
		onFuria = true
		
	if onFuria and not is_dead:
		attacking = false
		$AnimatedSprite.play("furia")
		defence = 90
		last_animation = "furia"
		push_power = 40
		direction = next_direction
		movement.x = direction*150
		move_and_slide_with_snap(movement, Vector2(0,2), Vector2.UP, true, 4, 0.9)
		
		pass
	if life <= 0 :
		is_dead = true
		$CanAttack.monitoring = false
		$Attack_fire.monitoring = false
		$Attack.monitorable = false
		$AnimatedSprite.play("death")
		last_animation = "death"
		
	if last_animation == "death" and $AnimatedSprite.frame == 5:
		$AnimatedSprite.stop() 
		
	if is_on_ceiling():
		movement.y = 0
	if !is_on_floor():
		movement.y+= gravity
	else:
		movement.y = gravity
		
	if can_attack and not onFuria and timerAttack:
		attacking = true
		next_direction = 0
		rng.randomize()
		var my_random_number = rng.randf_range(-1,1)
		if my_random_number >=-1 && my_random_number <0 and not escolhido and timerAttack:
			$AnimatedSprite.play("attack_Fire")
			last_animation = "attack_fire"
			escolhido = true
		elif my_random_number <=1 && my_random_number >0 and not escolhido and timerAttack:
			$AnimatedSprite.play("attack")
			last_animation = "attack"
			escolhido = true
			
	if last_animation == "attack_fire" and $AnimatedSprite.frame == 13:
		attacking = false
		escolhido = false
		$Attack_fire.monitoring = false
		$PickAnotherAttack.start()
	if last_animation == "attack" and $AnimatedSprite.frame == 7:
		attacking = false
		escolhido = false
		$Attack.monitoring = false
		$PickAnotherAttack.start()
	if last_animation == "attack_fire" and $AnimatedSprite.frame == 7:
		$Attack_fire.monitoring = true
		timerAttack = false
	if last_animation == "attack" and $AnimatedSprite.frame == 5:
		$Attack.monitoring = true
		timerAttack = false
	if last_animation == "furia" and $AnimatedSprite.frame ==0:
		$Attack_investida.monitoring = false
		$attack_punch.monitoring = false
		attacking_furia = false
	if last_animation == "furia" and $AnimatedSprite.frame <=11:
		
		next_direction = 0
		attacking_furia = true
	if last_animation == "furia" and $AnimatedSprite.frame>=12 and $AnimatedSprite.frame<15:
		
		$Attack_investida.monitoring = true
		attacking_furia = false
	if last_animation == "furia" and $AnimatedSprite.frame>=15 :
		$Attack_investida.monitoring = false
		$attack_punch.monitoring = true
		attacking_furia = true
		next_direction = 0
	if canFollow and not is_dead and not attacking  :
		
		$CanFollow.monitoring = false
		if player.position.x < position.x and next_direction != -1 and not attacking_furia:
			
			next_direction = -1
			$AnimatedSprite.scale.x = -1
			$CollisionShape2D.position.x = 13.708
			$CanAttack/CollisionShape2D.position.x = -49.554
			$Attack_fire/CollisionShape2D.position.x = -31.216
			$Attack/CollisionShape2D.position.x = -35.5
			$Attack/CollisionShape2D.scale.x = 1
			$Attack_investida/CollisionShape2D.position.x = -24.386
			$attack_punch/CollisionPolygon2D.position.x = -10.12
			push_power = -abs(push_power)
			push_power_fogo = -abs(push_power_fogo)
			next_direction_time = OS.get_ticks_msec()+react_time
		elif player.position.x > position.x and next_direction != 1 and not attacking_furia:
			next_direction = 1
			
			$AnimatedSprite.scale.x = 1
			$CollisionShape2D.position.x = -13.708
			$CanAttack/CollisionShape2D.position.x = 49.554
			$Attack_fire/CollisionShape2D.position.x = 31.216
			$Attack/CollisionShape2D.position.x = 35.5
			$Attack/CollisionShape2D.scale.x = -1
			$Attack_investida/CollisionShape2D.position.x = 24.386
			$attack_punch/CollisionPolygon2D.position.x = 10.12
			push_power = abs(push_power)
			push_power_fogo = abs(push_power_fogo)
			next_direction_time = OS.get_ticks_msec()+react_time
	if not is_dead :
		if OS.get_ticks_msec() > next_direction_time:
			direction = next_direction
			movement.x = direction*walk_speed
			move_and_slide_with_snap(movement, Vector2(0,2), Vector2.UP, true, 4, 0.9)
			update_animation()
	pass

func update_animation():
	if not attacking and not is_dead and not onFuria:
		$AnimatedSprite.play("walk")
		last_animation = "walk"
	pass

func _on_CanFollow_body_entered(body):
	if body.get_name() == "Haytham":
		canFollow = true
		$CanFollow/CollisionShape2D.disabled = true
		$CanFollow.monitoring = false


func _on_CanAttack_body_entered(body):
	if body.get_name() == "Haytham":
		can_attack = true


func _on_CanAttack_body_exited(body):
	if body.get_name() == "Haytham":
		can_attack = false

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


func _on_Attack_fire_body_entered(body):
	if body.get_name() == "Haytham":
		player.take_damage(position,strength,push_power_fogo, true)


func _on_Attack_body_entered(body):
	if body.get_name() == "Haytham":
		player.take_damage(position,strength,push_power)


func _on_Attack_investida_body_entered(body):
	if body.get_name() == "Haytham":
		player.take_damage(position,furia_strengh,push_power)
	pass # Replace with function body.


func _on_attack_punch_body_entered(body):
	if body.get_name() == "Haytham":
		player.take_damage(position,furia_strengh,push_power)
	pass # Replace with function body.


func _on_PickAnotherAttack_timeout():
	timerAttack = true
	pass # Replace with function body.
