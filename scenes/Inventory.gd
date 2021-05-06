extends Node2D
onready var player = get_tree().root.get_node("Inferno").get_node("Haytham")
onready var strength_xp_upgrade = int(pow(1.08, player.strength))
onready var defence_xp_upgrade = int(pow(1.08, player.defence))

func _process(delta):
	if  Input.is_action_just_pressed("inventory"):
		visible = !visible

func _on_Inventory_draw():
	$Inventory/Strength.text = str(player.strength)
	$Inventory/Defence.text = str(player.defence)
	$Inventory/Experience.text = str(player.experience)
	$Inventory/StrengthXPUpgrade.text = str(strength_xp_upgrade)
	$Inventory/DefenceXPUpgrade.text = str(defence_xp_upgrade)


func _on_DefenceUpgrade_pressed():
	if player.experience < defence_xp_upgrade:
		return
	player.experience -= defence_xp_upgrade
	player.defence += 1
	defence_xp_upgrade = int(pow(1.08, player.defence))
	$Inventory/Defence.text = str(player.defence)
	$Inventory/DefenceXPUpgrade.text = str(defence_xp_upgrade)
	$Inventory/Experience.text = str(player.experience)

func _on_StrengthUpgrade_pressed():
	if player.experience < strength_xp_upgrade:
		return
	player.experience -= strength_xp_upgrade
	player.strength += 1
	strength_xp_upgrade = int(pow(1.08, player.strength))
	$Inventory/Strength.text = str(player.strength)
	$Inventory/StrengthXPUpgrade.text = str(strength_xp_upgrade)
	$Inventory/Experience.text = str(player.experience)


