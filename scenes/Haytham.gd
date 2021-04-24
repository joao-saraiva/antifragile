extends KinematicBody2D

export var gravity = 10
export var run_speed = 140
export var walk_speed = 80
export var jump_speed = -300
export var movement = Vector2(0,0)
var last_movement_y = 0
var last_animation = ""
var last_mouse_position = Vector2(0,0)
var cursor_position = Vector2(0,0)
var esp32_left_joystick = Vector2(0,0)
var mouse_actived = true
var is_dead = false
var is_running = false
var hit = false
var esp32Jump = false
var esp32Attack = false
var esp32Run = false


# Esses status serão salvos por arquivo para não serem resetados
# cada vez q o jogo for iniciado. Estão sendo declarados aqui
# somente para teste
var life = 100
var strength = 1
var attack = 1
var defense = 1
var chaos = 0
var in_fury_state = false

func _ready():
	Serial.connect("jump",self,"jump")
	Serial.connect("run",self,"run")
	Serial.connect("attack",self,"EspAttack")
	Serial.connect("left_joystick",self,"esp32_left_joystick")
	Serial.connect("right_joystick",self,"esp32_right_joystick")

func run():
	esp32Run = !esp32Run

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
	print(look_angle()) #excluir essa linha depois
	last_movement_y = movement.y
	if is_on_ceiling():
		movement.y = 0
	if !is_on_floor():
		movement.y+= gravity
	else:
		movement.y = gravity
	
	if life <= 0:
		$AnimatedSprite.play("death")
		is_dead = true
		movement.x = 0
	
	if not is_dead:
		if (esp32Attack or Input.is_action_just_pressed("attack_slash")) and not is_landing() and not is_attacking():
			$Sword_hit_sound.play()
			esp32Attack = false
			attack()
		
		if hit:
			if not is_landing():
				if not $Hit.playing:
					$Hit.play()
				$AnimatedSprite.play("land")
				last_animation = "land"
				$AnimatedSprite.frame = 0
			movement.x -= movement.x*0.05
			if abs(movement.x) < 20:
				hit = false
		
		if not is_landing():
			var horizontal_axis
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
			
			if (esp32Jump or Input.is_action_just_pressed("jump")) and is_on_floor():
				$Swordhit/sword_strike.disabled = true
				$Sword_hit_sound.stop()
				movement.y = jump_speed
				esp32Jump = false
		elif abs(movement.x) <= run_speed:
			movement.x = 0
			
	move_and_slide_with_snap(movement, Vector2(0,2), Vector2.UP, true, 4, 0.9)
	if not is_dead:
		update_animations()

func update_animations():
	if not is_attacking() and not is_landing():
		if (not mouse_actived and cursor_position.x > 0 or mouse_actived and cursor_position.x > 512) and not is_running or movement.x > 0 and is_running:
			$AnimatedSprite.scale.x = 1
			$Swordhit/sword_strike.scale.x = 1
			$Swordhit/sword_strike.position.x = 11.914
		elif (not mouse_actived and cursor_position.x < 0 or mouse_actived and cursor_position.x < 512) and not is_running or movement.x < 0 and is_running:
			$AnimatedSprite.scale.x = -1
			$Swordhit/sword_strike.scale.x = -1
			$Swordhit/sword_strike.position.x = -11.914
	
	if is_on_floor():
		if last_movement_y > 500:
			$landing.play()
			$AnimatedSprite.play("land")
			
		elif abs(movement.x) > 0 and not is_attacking():
			if is_running:
				$AnimatedSprite.play("run")
			else:
				$AnimatedSprite.play("walk")
		elif not is_landing() and not is_attacking():
			$AnimatedSprite.play("idle")
	elif not is_attacking() or movement.y == jump_speed:
		if movement.y > 0:
			$AnimatedSprite.play("fall")
		else:
			$AnimatedSprite.play("jump")
	
	last_animation = $AnimatedSprite.animation 

func is_landing():
	return last_animation == "land" and $AnimatedSprite.frame != 2

func is_attacking():
	return last_animation == "attack_slash" and $AnimatedSprite.frame != 4

func look_angle():
	var opposite
	var adjacent
	if mouse_actived:
		adjacent = abs(512 - cursor_position.x)
		if 300 - cursor_position.y > 0:
			opposite = abs(300 - cursor_position.y)
		else:
			opposite = 0
	else:
		adjacent = abs(cursor_position.x)
		if cursor_position.y > 0:
			opposite = cursor_position.y
		else:
			opposite = 0
	
	var hypotenuse = sqrt(pow(opposite,2) + pow(adjacent,2))
	if hypotenuse == 0:
		return 0
	else:
		return asin(opposite/hypotenuse)*180/PI # angulo em graus

func attack():
	$AnimatedSprite.play("attack_slash")
	last_animation = $AnimatedSprite.animation
	$Swordhit/attack_on.start()

func _on_attack_off_timeout():
	$Swordhit/sword_strike.disabled = true

func _on_attack_on_timeout():
	if not last_animation == "jump":
		$Swordhit/sword_strike.disabled = false
		$Swordhit/attack_off.start()

func _on_Swordhit_body_entered(body):
	var enemy = get_parent().get_node(body.get_name())
	enemy.take_damage("slash")
