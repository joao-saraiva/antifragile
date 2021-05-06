extends KinematicBody2D

export var gravity = 10
export var run_speed = 140
export var walk_speed = 80
export var jump_speed = -300
export var movement = Vector2(0,0)
var last_movement = Vector2(0,0)
var last_animation = ""
var attack_style = "slash"
var last_mouse_position = Vector2(0,0)
var cursor_position = Vector2(0,0)
var esp32_left_joystick = Vector2(0,0)
var current_look_angle = 0
var mouse_actived = true
var is_dead = false
var is_running = false
var hit = false
var wielded_shield = false
var just_hitted = true
var esp32Jump = false
var esp32Attack = false
var esp32Run = false
var esp32Shield = false
var esp32ChangeAttackStyle = false
var walkSound = true
var deathSound = true
var chaos_multiplier = 1
var reset_chaos_bar = false
var inventory_open = false
# Esses status serão salvos por arquivo para não serem resetados
# cada vez q o jogo for iniciado. Estão sendo declarados aqui
# somente para teste
var life = 100
export var experience = 5001
export var strength = 1
export var defence = 33
var chaos = 0
var chaos_enable = true
var sword = "Chaos_longsword"

func _ready():
	Socket.connect("jump",self,"jump")
	Socket.connect("run",self,"run")
	Socket.connect("attack",self,"EspAttack")
	Socket.connect("left_joystick",self,"esp32_left_joystick")
	Socket.connect("right_joystick",self,"esp32_right_joystick")

func run():
	esp32Run = !esp32Run

func changeAttackStyle():
	esp32ChangeAttackStyle = true

func jump():
	esp32Jump = true;

func EspAttack():
	esp32Attack = true;

func _process(delta):
	if get_viewport().get_mouse_position() != last_mouse_position:
		cursor_position = get_viewport().get_mouse_position()
	elif abs(cursor_position.x) > 1 or abs(cursor_position.y) > 1:
		mouse_actived = true
	last_mouse_position = get_viewport().get_mouse_position()

func esp32_right_joystick(x, y):
	mouse_actived = false
	cursor_position = Vector2(float(x), float(y))

func esp32_left_joystick(x):
	if mouse_actived:
		cursor_position = Vector2(0,0)
	mouse_actived = false
	esp32_left_joystick = Vector2(int(x),0)

func _physics_process(delta):
	last_movement = movement
	if is_on_ceiling():
		movement.y = 0
	if !is_on_floor():
		movement.y+= gravity
	else:
		movement.y = gravity
	
	if life <= 0:
		if deathSound:
			$death.play()
			deathSound = false
			$walk.stop()
		$AnimatedSprite.play("death"+sword)
		is_dead = true
		$CollisionShape2D.disabled = true
		movement.y = 0
		movement.x = 0
		$GameOverCanvasLayer/Black.visible = true
	
	if not is_dead:
		if chaos_enable and chaos > 0 and chaos_multiplier != 4 and not reset_chaos_bar:
			if chaos == 100:
				chaos_multiplier = 4
				$Chaos.start()
			else:
				chaos -= 0.01
				if chaos < 0:
					chaos = 0
		if reset_chaos_bar:
			chaos -= 2
			if chaos == 0:
				reset_chaos_bar = true
		if sword != "None" and esp32ChangeAttackStyle or Input.is_action_just_pressed("change_attack_style"):
			if attack_style == "slash":
				attack_style = "stab"
			else:
				attack_style = "slash"
			esp32ChangeAttackStyle = false
		
		if hit:
			if just_hitted:
				just_hitted = false;
			$AnimatedSprite.play("land"+sword)
			last_animation = "land"+sword
			movement.x -= movement.x*0.05
			if abs(movement.x) < 20:
				hit = false
				just_hitted = true
		
		if not is_landing() and not inventory_open:
			var horizontal_axis
			if not wielded_shield:
				if mouse_actived:
					horizontal_axis = Input.get_action_strength("right")-Input.get_action_strength("left")
				else:
					horizontal_axis = esp32_left_joystick.x
				if esp32Run or Input.is_action_pressed("run"):
					movement.x = horizontal_axis*run_speed
					is_running = true
				else:
					movement.x = horizontal_axis*walk_speed
					is_running = false
			
				if sword != "None" and (esp32Attack or Input.is_action_just_pressed("attack")) and not is_attacking():
					esp32Attack = false
					attack()
			elif $AnimatedSprite.frame == 11:
				$AnimatedSprite.frame = 3
			if esp32Shield or Input.is_action_pressed("shield") and is_on_floor():
				wielded_shield = true
				$AnimatedSprite.play("shield"+sword)
				$Sword_slash_sound.stop()
				$Sword_stab_sound.stop()
				movement.x = 0
				last_animation = $AnimatedSprite.animation
			elif (not esp32Shield and not mouse_actived) or Input.is_action_just_released("shield"):
				wielded_shield = false
				
			if (esp32Jump or Input.is_action_just_pressed("jump")) and is_on_floor():
				$Swordhit/sword_slash.disabled = true
				$Sword_slash_sound.stop()
				$Sword_stab_sound.stop()
				movement.y = jump_speed
				esp32Jump = false
				wielded_shield = false
		elif abs(movement.x) <= run_speed:
			movement.x = 0
			
	move_and_slide_with_snap(movement, Vector2(0,2), Vector2.UP, true, 4, 0.9)
	
	if not is_dead and (not is_attacking() or movement.y == jump_speed):
		update_animations()
		update_attack_hitbox()

func update_animations():
	if not is_attacking() and not is_landing():
		if (not mouse_actived and cursor_position.x > 0 or mouse_actived and cursor_position.x > 640) and not is_running or movement.x > 0 and is_running:
			$AnimatedSprite.scale.x = 1
			$Swordhit/sword_slash.scale.x = 1
			$Swordhit/sword_slash.position.x = 11.914
			$Swordhit/sword_stab.scale.x = 1
			$Swordhit/sword_stab.position.x = 11
		elif (not mouse_actived and cursor_position.x < 0 or mouse_actived and cursor_position.x < 640) and not is_running or movement.x < 0 and is_running:
			$AnimatedSprite.scale.x = -1
			$Swordhit/sword_slash.scale.x = -1
			$Swordhit/sword_slash.position.x = -11.914
			$Swordhit/sword_stab.scale.x = -1
			$Swordhit/sword_stab.position.x = -11
	if is_on_floor():
		if last_movement.y > 500:
			$landing.play()
			$AnimatedSprite.play("land"+sword)	
		elif abs(movement.x) > 0 and not is_attacking():
			if walkSound:
				$walk.play()
				walkSound = false
			if is_running:
				$AnimatedSprite.play("run"+sword)
			else:
				$AnimatedSprite.play("walk"+sword)
		elif not is_landing() and not is_attacking() and not wielded_shield:
			$AnimatedSprite.play("idle"+sword)
			$walk.stop()
			walkSound = true
	elif not is_attacking() or movement.y == jump_speed:
		if movement.y > 0:
			$AnimatedSprite.play("fall"+sword)
			$walk.stop()
			walkSound = true
		else:
			$AnimatedSprite.play("jump"+sword)
			$walk.stop()
			walkSound = true
	last_animation = $AnimatedSprite.animation

func is_landing():
	return last_animation == "land"+sword and $AnimatedSprite.frame != 2

func is_attacking():
	return last_animation == attack_style and $AnimatedSprite.frame != 4

func look_angle():
	var opposite
	var adjacent
	if mouse_actived:
		adjacent = abs(640 - cursor_position.x)
		opposite = 360 - cursor_position.y
	else:
		adjacent = abs(cursor_position.x)
		opposite = cursor_position.y
	
	var hypotenuse = sqrt(pow(opposite,2) + pow(adjacent,2))
	if hypotenuse == 0:
		return 0
	else:
		return asin(opposite/hypotenuse)*180/PI # angulo em graus

func attack():
	$AnimatedSprite.play(attack_style+str(current_look_angle)+sword)
	last_animation = attack_style
	if attack_style == "slash":
		$Swordhit/attack_on.wait_time = 0.16
	else:
		$Sword_stab_sound.play()
		$Swordhit/attack_on.wait_time = 0.12
	$Swordhit/attack_on.start()

func take_damage(enemy, enemy_strength,push_power, ignore_shield = false):
	var damage
	var distance = enemy.x - position.x
	if wielded_shield and ((distance < 0 and $AnimatedSprite.scale.x < 0) or (enemy.x - position.x > 0 and $AnimatedSprite.scale.x > 0)) and not ignore_shield:
		$block.play()
		damage = (enemy_strength*15)/(10*defence*chaos_multiplier)
		life -= damage
	else:
		wielded_shield = false
		damage = (enemy_strength*15)/(defence*chaos_multiplier)
		life -= damage
		movement.x = push_power*20
		if damage >= 10:
			hit = true
	print("player: "+str(life))
	if damage >= 3:
		$Hit.play()

func _on_attack_off_timeout():
	$Swordhit/sword_slash.disabled = true
	$Swordhit/sword_stab.disabled = true

func _on_attack_on_timeout():
	if not last_animation == "jump" and last_animation == attack_style:
		if attack_style == "slash":
			$Swordhit/sword_slash.disabled = false
			$Sword_slash_sound.play()
		else:
			$Swordhit/sword_stab.disabled = false
		$Swordhit/attack_off.start()

func _on_Swordhit_body_entered(body):
	var enemy = get_parent().get_node(body.get_name())
	enemy.take_damage()

func update_attack_hitbox():
	var degree = look_angle()
	if degree >= 17 and degree < 60:
		if $AnimatedSprite.scale.x == 1:
			$Swordhit/sword_slash.rotation = -0.523599
			$Swordhit/sword_stab.rotation = -0.523599
			$Swordhit/sword_slash.position.x = 11.273 
			$Swordhit/sword_stab.position.x = 10.652
		else:
			$Swordhit/sword_slash.rotation = 0.523599
			$Swordhit/sword_stab.rotation = 0.523599
			$Swordhit/sword_slash.position.x = -11.273 
			$Swordhit/sword_stab.position.x = -10.652
		$Swordhit/sword_slash.position.y = -9.283
		$Swordhit/sword_stab.position.y = -10.778
		current_look_angle = 30
	elif degree >= 38:
		if $AnimatedSprite.scale.x == 1:
			$Swordhit/sword_slash.rotation = -1.0472
			$Swordhit/sword_stab.rotation = -1.0472
			$Swordhit/sword_slash.position.x = 7.914
			$Swordhit/sword_stab.position.x = 6.47
		else:
			$Swordhit/sword_slash.rotation = 1.0472
			$Swordhit/sword_stab.rotation = 1.0472
			$Swordhit/sword_slash.position.x = -7.914
			$Swordhit/sword_stab.position.x = -6.47
		$Swordhit/sword_slash.position.y = -15.061
		$Swordhit/sword_stab.position.y = -14.147
		current_look_angle = 60
	elif degree <= -17:
		if $AnimatedSprite.scale.x == 1:
			$Swordhit/sword_slash.rotation = 0.523599
			$Swordhit/sword_stab.rotation = 0.523599
			$Swordhit/sword_slash.position.x = 10.323
			$Swordhit/sword_stab.position.x = 10.354
		else:
			$Swordhit/sword_slash.rotation = -0.523599
			$Swordhit/sword_stab.rotation = -0.523599
			$Swordhit/sword_slash.position.x = -10.323
			$Swordhit/sword_stab.position.x = -10.354
		$Swordhit/sword_slash.position.y = 6.572
		$Swordhit/sword_stab.position.y = 3.551
		current_look_angle = -30
	else:
		if $AnimatedSprite.scale.x == 1:
			$Swordhit/sword_slash.position.x = 11.914
			$Swordhit/sword_stab.position.x = 11
		else:
			$Swordhit/sword_slash.position.x = -11.914
			$Swordhit/sword_stab.position.x = -11
		$Swordhit/sword_slash.rotation = 0
		$Swordhit/sword_stab.rotation = 0
		$Swordhit/sword_slash.position.y = -2.974
		$Swordhit/sword_stab.position.y = -4
		current_look_angle = 0

func _on_death_finished():
	print("acabamos")
	get_tree().reload_current_scene()


func _on_Chaos_timeout():
	reset_chaos_bar = true
	chaos_multiplier = 1


func _on_Inventory_visibility_changed():
	inventory_open = !inventory_open
