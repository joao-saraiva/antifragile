extends KinematicBody2D

export var gravity = 10
export var walk_speed = 120
export var jump_speed = -300
export var movement = Vector2(0,0)
var last_movement_y = 0
var last_animation = ""

# Esses status serão salvos por arquivo para não serem resetados
# cada vez q o jogo for iniciado. Estão sendo declarados aqui
# somente para teste
var life = 100
var strength = 1
var attack = 1
var defense = 1
var chaos = 0
var in_fury_state = false

func _physics_process(delta):
	last_movement_y = movement.y
	if is_on_ceiling():
		movement.y = 0
	if !is_on_floor():
		movement.y+= gravity
	else:
		movement.y = gravity
		
	if not playing_land_animation():
		var horizontal_axis = Input.get_action_strength("right")-Input.get_action_strength("left")
		
		movement.x = horizontal_axis*walk_speed
		if Input.is_action_just_pressed("jump") and is_on_floor():
			movement.y = jump_speed
	else:
		movement.x = 0
	
	move_and_slide_with_snap(movement, Vector2(0,2), Vector2.UP, true, 4, 0.9)
	update_animations()
	
func update_animations():
	if movement.x > 0:
		$AnimatedSprite.scale.x = 1
	elif movement.x < 0:
		$AnimatedSprite.scale.x = -1
		
	if is_on_floor():
		if last_movement_y > 500:
			$AnimatedSprite.play("land")
		elif Input.is_action_just_pressed("attack_strike"):
			attacking()
		elif abs(movement.x) > 0:
			if not playing_attack_animation():
				$AnimatedSprite.play("walking")
		elif not playing_land_animation() :
			if not playing_attack_animation():
				$AnimatedSprite.play("idle")
	else:
		if movement.y > 0:
			if not playing_attack_animation():
				$AnimatedSprite.play("fall")
				if Input.is_action_just_pressed("attack_strike"):
					attacking()
		else:
			if not playing_attack_animation():
				$AnimatedSprite.play("jump")
				if Input.is_action_just_pressed("attack_strike"):
					attacking()
					pass
					
	
	last_animation = $AnimatedSprite.animation 

func playing_land_animation():
	return last_animation == "land" and $AnimatedSprite.frame != 2
func playing_attack_animation():
	return last_animation == "attack_Strike" and $AnimatedSprite.frame !=3
	
func attacking():
	
	$AnimatedSprite.play("attack_Strike")
	$Swordhit/sword_strike.disabled = false
	$Swordhit/wait.start()
	
		


func _on_wait_timeout():
	$Swordhit/sword_strike.disabled = true
	pass # Replace with function body.
