extends KinematicBody2D


var canAttack = false
var is_dead = false
var life = 0.5
onready var player = get_parent().get_node("Haytham")

func _ready():
	pass 

func _process(delta):
	
	if canAttack and not is_dead:
		pass
	


func _on_CanAttack_body_entered(body):
	canAttack = true
	pass # Replace with function body.


func _on_CanAttack_body_exited(body):
	canAttack = false
	pass # Replace with function body.
