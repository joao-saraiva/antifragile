extends Node2D
var slot = ["None", "None"]
var slot_selected = 0
var inventory_open = false
signal hotbar1(item)
signal hotbar2(item)
signal item_used(slot)

func _ready():
	emit_signal("hotbar1", slot[0])

func _process(delta):
	if Input.is_action_just_pressed("hotbar1"):
		if slot[0] == "life_potion":
			emit_signal("hotbar2", "None")
		else:
			emit_signal("hotbar1", slot[0])
		slot_selected = 0
	if Input.is_action_just_pressed("hotbar2"):
		if slot[1] == "life_potion":
			emit_signal("hotbar2", "None")
		else:
			emit_signal("hotbar2", slot[1])
		slot_selected = 1
	if  Input.is_action_just_pressed("inventory"):
		if slot_selected == 0:
			emit_signal("hotbar1", slot[0])
		else:
			emit_signal("hotbar2", slot[1])
		inventory_open = !inventory_open
	if inventory_open == false and slot[slot_selected] == "life_potion" and Input.is_action_just_pressed("attack"):
		print("aa")
		emit_signal("item_used", slot_selected)
		if slot_selected == 0:
			emit_signal("hotbar1", "None")
		else:
			emit_signal("hotbar2", "None")

func _on_Inventory_hotbar1_items(item):
	if item != null:
		$slot1.texture = load("res://assets/Items/"+item.item_name+".png")
		slot[0] = item.item_name
	else:
		$slot1.texture = null
		slot[0] = "None"

func _on_Inventory_hotbar2_items(item):
	if item != null:
		$slot2.texture = load("res://assets/Items/"+item.item_name+".png")
		slot[1] = item.item_name
	else:
		$slot2.texture = null
		slot[1] = "None"
