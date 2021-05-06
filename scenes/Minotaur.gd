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
onready var player = get_parent().get_node("Haytham")
var life = 1
var strength = 90
var defence = 70
var is_dead = false
var push_power = 30
var push_power_fogo = 10
var rng = RandomNumberGenerator.new()

func _ready():
	$AnimatedSprite.play("walk")

func _process(delta):
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
	if can_attack:
		attacking = true
		next_direction = 0
		rng.randomize()
		var my_random_number = rng.randf_range(-1,1)
		if my_random_number >=-1 && my_random_number <0 and not escolhido:
			$AnimatedSprite.play("attack_Fire")
			last_animation = "attack_fire"
			escolhido = true
		elif my_random_number <=1 && my_random_number >0 and not escolhido:
			$AnimatedSprite.play("attack")
			last_animation = "attack"
			escolhido = true
			
	if last_animation == "attack_fire" and $AnimatedSprite.frame == 13:
		attacking = false
		escolhido = false
		$Attack_fire.monitoring = false
	if last_animation == "attack" and $AnimatedSprite.frame == 7:
		attacking = false
		escolhido = false
		$Attack.monitoring = false
	if last_animation == "attack_fire" and $AnimatedSprite.frame == 7:
		$Attack_fire.monitoring = true
	if last_animation == "attack" and $AnimatedSprite.frame == 5:
		$Attack.monitoring = true
	if canFollow and not is_dead and not attacking  :
		
		$CanFollow.monitoring = false
		if player.position.x < position.x and next_direction != -1:
			next_direction = -1
			$AnimatedSprite.scale.x = -1
			$CollisionShape2D.position.x = 13.708
			$CanAttack/CollisionShape2D.position.x = -49.554
			$Attack_fire/CollisionShape2D.position.x = -31.216
			$Attack/CollisionShape2D.position.x = -35.5
			$Attack/CollisionShape2D.scale.x = 1
			push_power = -abs(push_power)
			push_power_fogo = -abs(push_power_fogo)
			next_direction_time = OS.get_ticks_msec()+react_time
		elif player.position.x > position.x and next_direction != 1:
			next_direction = 1
			$AnimatedSprite.scale.x = 1
			$CollisionShape2D.position.x = -13.708
			$CanAttack/CollisionShape2D.position.x = 49.554
			$Attack_fire/CollisionShape2D.position.x = 31.216
			$Attack/CollisionShape2D.position.x = 35.5
			$Attack/CollisionShape2D.scale.x = -1
			push_power = abs(push_power)
			push_power_fogo = abs(push_power_fogo)
			next_direction_time = OS.get_ticks_msec()+react_time
	if not is_dead:
		if OS.get_ticks_msec() > next_direction_time:
			direction = next_direction
			movement.x = direction*walk_speed
			move_and_slide_with_snap(movement, Vector2(0,2), Vector2.UP, true, 4, 0.9)
			update_animation()
	pass

func update_animation():
	if not attacking and not is_dead:
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
