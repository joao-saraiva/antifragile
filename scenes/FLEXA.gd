extends Area2D


var direction : Vector2 = Vector2.LEFT
var escala
var hitHaytham = false
var gone = false
var flexa_strengh
var flexa_push_power
signal dano()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass
	
func _process(delta):
	translate(direction*70*delta)
	$Sprite.scale.x = escala


func _on_Area2D_body_entered(body):
	if body.get_name() == "Haytham":
		hitHaytham = true
		queue_free()
		body.take_damage(position,flexa_strengh,flexa_push_power)
		emit_signal("dano")
		
		
		
	pass # Replace with function body.
