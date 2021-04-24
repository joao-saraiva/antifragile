extends KinematicBody2D

export var gravity = 10
export var run_speed = 140
export var walk_speed = 80
export var jump_speed = -300
export var movement = Vector2(0,0)
var mouse_position = Vector2(0,0)
var mouse_actived = true
var last_movement_y = 0
var last_animation = ""
var is_dead = false
var is_running = false
var esp32Esquerda = false
var esp32Direita = false
var esp32Jump = false
var esp32Attack = false
var esp32Cesquerda = false
var esp32Cdireita = false
# Esses status serão salvos por arquivo para não serem resetados
# cada vez q o jogo for iniciado. Estão sendo declarados aqui
# somente para teste
var life = 1
var strength = 1
var attack = 1
var defense = 1
var chaos = 0
var in_fury_state = false

func _ready():
	Serial.connect("esquerda",self,"esquerda")
	Serial.connect("parado",self,"parado")
	Serial.connect("direita",self,"direita")
	Serial.connect("jump",self,"jump")
	Serial.connect("attack",self,"EspAttack")
	Serial.connect("cesquerda",self,"Cesquerda")
	Serial.connect("cdireita",self,"cDireita")
func parado():
	esp32Esquerda = false;
	esp32Direita = false;

func esquerda():
	esp32Esquerda = true;

func direita():
	esp32Direita = true;
	
func jump():
	esp32Jump = true;
	
func EspAttack():
	esp32Attack = true;
	
func _process(delta):
	mouse_position = get_viewport().get_mouse_position()
	
func Cesquerda():
	esp32Cesquerda = true;
	
func cDireita():
	esp32Cdireita = true;
	
func _physics_process(delta):
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
		if Input.is_action_just_pressed("attack_slash") and not is_landing() and not is_attacking():
			$Sword_hit_sound.play()
			attack()
			
		if esp32Attack and not is_landing() and not is_attacking():
			esp32Attack = false
			$Sword_hit_sound.play()
			attack()
		if not is_landing():
			var horizontal_axis = Input.get_action_strength("right")-Input.get_action_strength("left")
			if Input.is_action_pressed("run"):
				movement.x = horizontal_axis*run_speed
				is_running = true
			else:
				movement.x = horizontal_axis*walk_speed
				is_running = false
			
			if Input.is_action_just_pressed("jump") and is_on_floor():
				$Swordhit/sword_strike.disabled = true
				$Sword_hit_sound.stop()
				movement.y = jump_speed
		else:
			movement.x = 0
		if esp32Jump && is_on_floor() :
			$Swordhit/sword_strike.disabled = true
			movement.y = jump_speed
			esp32Jump = false
		if esp32Esquerda == true:
			movement.x = -1*run_speed
		if esp32Direita == true:
			movement.x = 1*run_speed
	
		
	move_and_slide_with_snap(movement, Vector2(0,2), Vector2.UP, true, 4, 0.9)
	if not is_dead:
		update_animations()

func update_animations():
	if not is_attacking():
		if esp32Cesquerda and not is_running or movement.x > 0 and is_running :
			$AnimatedSprite.scale.x = -1
			$Swordhit/sword_strike.scale.x = -1
			$Swordhit/sword_strike.position.x = -11.914
			esp32Cesquerda = false
			mouse_actived = false
			print("esquerda")
			
		if esp32Cdireita and not is_running or movement.x > 0 and is_running :
			$AnimatedSprite.scale.x = 1
			$Swordhit/sword_strike.scale.x = 1
			$Swordhit/sword_strike.position.x = 11.914
			mouse_actived = false
			esp32Cdireita = false
			print("direita")
			
		if mouse_position.x > 512 and mouse_actived and not is_running or movement.x > 0 and is_running :
			$AnimatedSprite.scale.x = 1
			$Swordhit/sword_strike.scale.x = 1
			$Swordhit/sword_strike.position.x = 11.914
		elif mouse_position.x < 512 and mouse_actived and not is_running or movement.x < 0 and is_running :
			
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
