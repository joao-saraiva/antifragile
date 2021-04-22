extends KinematicBody2D

export var gravity = 10
export var walk_speed = 120
export var jump_speed = -300
export var movement = Vector2(0,0)
var mouse_position = Vector2(0,0)
var last_movement_y = 0
var last_animation = ""
var is_dead = false
var esp32Esquerda = false
var esp32Direita = false

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

func parado():
	esp32Esquerda = false;
	esp32Direita = false;

func esquerda():
	esp32Esquerda = true;

func direita():
	esp32Direita = true;
	
func _process(delta):
	mouse_position = get_viewport().get_mouse_position()

func _physics_process(delta):
	last_movement_y = movement.y
	if is_on_ceiling():
		movement.y = 0
	if !is_on_floor():
		movement.y+= gravity
	else:
		movement.y = gravity
	
	if not is_dead:	
		if Input.is_action_just_pressed("attack_strike") and not is_landing() and not is_attacking():
			attack()
			
		if not is_landing():
			var horizontal_axis = Input.get_action_strength("right")-Input.get_action_strength("left")
			movement.x = horizontal_axis*walk_speed
			
			if Input.is_action_just_pressed("jump") and is_on_floor():
				movement.y = jump_speed
		else:
			movement.x = 0
		
		if esp32Esquerda == true:
			movement.x = -1*walk_speed
		if esp32Direita == true:
			movement.x = 1*walk_speed
	
	move_and_slide_with_snap(movement, Vector2(0,2), Vector2.UP, true, 4, 0.9)
	if not is_dead:
		update_animations()

func update_animations():
	if mouse_position.x > 512:
		$AnimatedSprite.scale.x = 1
		$Swordhit/sword_strike.scale.x = 1
		$Swordhit/sword_strike.position.x = 11.914
	elif mouse_position.x < 512:
		$AnimatedSprite.scale.x = -1
		$Swordhit/sword_strike.scale.x = -1
		$Swordhit/sword_strike.position.x = -11.914
	
	if life <= 0:
		$AnimatedSprite.play("death")
		is_dead = true
		movement.x = 0
	elif is_on_floor():
		if last_movement_y > 500:
			$AnimatedSprite.play("land")
		elif abs(movement.x) > 0 and not is_attacking():
			$AnimatedSprite.play("walking")
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
	return last_animation == "attack_Strike" and $AnimatedSprite.frame != 4

func attack():
	$AnimatedSprite.play("attack_Strike")
	last_animation = $AnimatedSprite.animation
	$Swordhit/sword_strike.disabled = false
	#print("on")
	$Swordhit/wait.start()

func _on_wait_timeout():
	$Swordhit/sword_strike.disabled = true
	#print("off")

func _on_Swordhit_body_entered(body):
	var enemy = get_parent().get_node(body.get_name())
	enemy.take_damage("slash")
