extends ProgressBar

func _physics_process(delta):
	if get_tree().root.get_node("Inferno").get_node("Haytham").life <= 0:
		self.visible = false
	
	value = get_tree().root.get_node("Inferno").get_node("Haytham").chaos
	
	if value == 100 and $AnimatedSprite.animation == "not_in_furystate":
		$AnimatedSprite.play("starting_furystate")
	elif $AnimatedSprite.animation == "starting_furystate" and $AnimatedSprite.frame == 9:
		$AnimatedSprite.play("in_furystate")
	elif $AnimatedSprite.animation == "in_furystate" and value < 100:
		$AnimatedSprite.play("exiting_furystate")
	elif $AnimatedSprite.animation == "exiting_furystate" and $AnimatedSprite.frame == 8:
		$AnimatedSprite.play("not_in_furystate")
