extends ProgressBar

func _physics_process(delta):
	if value <= 0:
		self.visible = false
	
	value = get_tree().root.get_node("Inferno").get_node("Haytham").life
