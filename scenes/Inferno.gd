extends Node2D



func _ready():
	pass
	
	
	

	





func _on_DialogArea_body_entered(body):
	if body.get_name() == "Haytham":
		$InterfaceLayer/Control/DialogueBox.visible = true
	pass 
