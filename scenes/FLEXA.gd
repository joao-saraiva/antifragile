extends Area2D


var direction : Vector2 = Vector2.LEFT
var escala
var hitHaytham = false
var gone = false
var flexa_strengh
var flexa_push_power
var archer_position
signal dano()

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.start()
	pass
	
func _process(delta):
	translate(direction*150*delta)
	$Sprite.scale.x = escala


func _on_Area2D_body_entered(body):
	if body.get_name() == "Haytham":
		hitHaytham = true
		queue_free()
		body.take_damage(archer_position,flexa_strengh,flexa_push_power)
		emit_signal("dano")
		
		
		
	pass # Replace with function body.


func _on_Timer_timeout():
	queue_free()
	pass # Replace with function body.
