extends Control


var dialog = [
	"Parabens haytham voce ja percebeu o que aconteceu ?",
	"isso mesmo você morreu apenas aceite o seu destino filho do caos e fique ao meu lado",
	"Voce quer resolver seus assuntos ? , tudo bem"
]
var dialog_index = 0
var finished = false

# 
func _ready():
	load_dialog()
	pass 
func _process(delta):
	if finished:
		$"next-indicator".visible = finished
		$"next-indicator/AnimationPlayer".play("idle")
	$"next-indicator".visible = finished
	if Input.is_action_just_pressed("enter"):
		load_dialog()
func load_dialog():
	if dialog_index <dialog.size():
		finished = false
		$RichTextLabel.bbcode_text = dialog[dialog_index]
		$RichTextLabel.percent_visible = 0
		$Tween.interpolate_property(
			$RichTextLabel,"percent_visible",0,1,1,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT
		)
		$Tween.start()
	else:
		get_tree().change_scene("res://scenes/BattleField.tscn")
		queue_free()
	dialog_index += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Tween_tween_completed(object, key):
	finished = true
