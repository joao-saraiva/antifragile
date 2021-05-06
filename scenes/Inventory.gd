extends Node2D
onready var player = get_tree().root.get_node("Inferno").get_node("Haytham")
onready var strength_xp_upgrade = int(pow(1.08, player.strength))
onready var defence_xp_upgrade = int(pow(1.08, player.defence))
var holding_item = null
const SlotClass = preload("res://scenes/Slot.gd")

func _process(delta):
	if  Input.is_action_just_pressed("inventory"):
		visible = !visible

func _ready():
	for inv_slots in $Inventory_gui/GridContainer.get_children():
		inv_slots.connect("gui_input", self, "slot_gui_input", [inv_slots])

func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			if holding_item != null:
				if !slot.item:
					slot.putIntoSlot(holding_item)
					holding_item = null
				else:
					var aux = slot.item
					slot.pickFromSlot()
					aux.global_position.x = event.global_position.x-64
					aux.global_position.y = event.global_position.y-64
					slot.putIntoSlot(holding_item)
					holding_item = aux
			elif slot.item:
				holding_item = slot.item
				slot.pickFromSlot()
				holding_item.global_position.x = get_global_mouse_position().x-64
				holding_item.global_position.y = get_global_mouse_position().y-64

func _input(event):
	if holding_item:
		holding_item.global_position.x = get_global_mouse_position().x-64
		holding_item.global_position.y = get_global_mouse_position().y-64
func _on_Inventory_draw():
	$Inventory_gui/Strength.text = str(player.strength)
	$Inventory_gui/Defence.text = str(player.defence)
	$Inventory_gui/Experience.text = str(player.experience)
	$Inventory_gui/StrengthXPUpgrade.text = str(strength_xp_upgrade)
	$Inventory_gui/DefenceXPUpgrade.text = str(defence_xp_upgrade)


func _on_DefenceUpgrade_pressed():
	if player.experience < defence_xp_upgrade:
		return
	player.experience -= defence_xp_upgrade
	player.defence += 1
	defence_xp_upgrade = int(pow(1.08, player.defence))
	$Inventory_gui/Defence.text = str(player.defence)
	$Inventory_gui/DefenceXPUpgrade.text = str(defence_xp_upgrade)
	$Inventory_gui/Experience.text = str(player.experience)

func _on_StrengthUpgrade_pressed():
	if player.experience < strength_xp_upgrade:
		return
	player.experience -= strength_xp_upgrade
	player.strength += 1
	strength_xp_upgrade = int(pow(1.08, player.strength))
	$Inventory_gui/Strength.text = str(player.strength)
	$Inventory_gui/StrengthXPUpgrade.text = str(strength_xp_upgrade)
	$Inventory_gui/Experience.text = str(player.experience)


