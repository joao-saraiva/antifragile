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
var can_attack = false
var tocou = false
var is_hit = false
onready var player = get_parent().get_node("Haytham")
var life = 200
var strength = 90
var defense = 70
var is_dead = false
var push_power = 30

func _ready():
	$AnimatedSprite.play("idle")
	pass #
func _process(delta):
	
	
	if canFollow:
		if canFollow and not is_dead:
			$CanFollow.monitoring = false
			if player.position.x < position.x and next_direction != -1:
					next_direction = -1
					$AnimatedSprite.scale.x = 1
					$CanFollow/FollowShape.scale.x = -1
					$CanFollow/FollowShape.position.x = -169.314
					push_power *= -1
					next_direction_time = OS.get_ticks_msec()+react_time
			elif player.position.x > position.x and next_direction != 1:
					next_direction = 1
					$AnimatedSprite.scale.x =- 1
					$CanFollow/FollowShape.scale.x = 1
					$CanFollow/FollowShape.position.x = 169.314
					push_power *= -1
					next_direction_time = OS.get_ticks_msec()+react_time
		if not is_dead:
			if OS.get_ticks_msec() > next_direction_time:
				direction = next_direction
				movement.x = direction*walk_speed
				move_and_slide_with_snap(movement, Vector2(0,2), Vector2.UP, true, 4, 0.9)
	


func _on_CanFollow_body_entered(body):
	if body.get_name() == "Haytham":
		canFollow = true
	
	
	
func take_damage():
	
	if player.attack_style == "slash":
		var damage = (3*Swords.swordAtributes(player.sword,player.attack_style)+3*player.strength*player.chaos_multiplier)/defense
		life -= damage
	else:
		var damage = 0.5 * (3*Swords.swordAtributes(player.sword,player.attack_style)+3*player.strength*player.chaos_multiplier)/defense
		life -= damage
	if life <= 0:
		if player.chaos + 50 > 100:
			player.chaos = 100
		else:
			player.chaos += 50


