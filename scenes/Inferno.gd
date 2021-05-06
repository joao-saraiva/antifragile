extends Node2D

var ativadou = false

func _ready():

	pass
	
	
	

	





func _on_DialogArea_body_entered(body):
	if body.get_name() == "Haytham":
		
		if not ativadou:
			$InterfaceLayer/Control/DialogueBox.visible = true
			ativadou = true
		
	pass 
