extends Area2D


var direction : Vector2 = Vector2.LEFT
var escala
var hitHaytham = false
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass
	
func _process(delta):
	translate(direction*70*delta)
	$Sprite.scale.x = escala


func _on_Area2D_body_entered(body):
	if body.get_name() == "Haytham":
		hitHaytham = true
		print(hitHaytham)
		
		
		
	pass # Replace with function body.
