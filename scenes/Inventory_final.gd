extends Node2D


onready var player = get_tree().root.get_node("FinalBoss").get_node("Haytham")
onready var strength_xp_upgrade = int(pow(1.08, player.strength))
onready var defence_xp_upgrade = int(pow(1.08, player.defence))
var holding_item = null
const ItemClass = preload("res://assets/Items/Item.tscn")
const SlotClass = preload("res://scenes/Slot.gd")
var last_slot = null
var inventory_vector = ["None", "None", "None", "None", "None", "None", "None", "None"]
onready var inventory_slots = $Inventory_gui/GridContainer.get_children()
onready var hotbar_slots = $Inventory_gui/GridContainer2.get_children()

signal hotbar1_items(item)
signal hotbar2_items(item)

func _process(delta):
	if  Input.is_action_just_pressed("inventory"):
		visible = !visible
		if holding_item:
			last_slot.putIntoSlot(holding_item)
			if last_slot.name == "hotbar1":
				emit_signal("hotbar1_items", holding_item)
			elif last_slot.name == "hotbar2":
				emit_signal("hotbar2_items", holding_item)
			holding_item = null

func _ready():
	for inv_slots in inventory_slots:
		inv_slots.connect("gui_input", self, "slot_gui_input", [inv_slots])
	var hot_bars = $Inventory_gui/GridContainer2.get_children()
	hot_bars[0].connect("gui_input", self, "hotbar1_gui_input", [hot_bars[0]])
	hot_bars[1].connect("gui_input", self, "hotbar2_gui_input", [hot_bars[1]])
	emit_signal("hotbar1_items", $Inventory_gui/GridContainer2/hotbar1.item)
	emit_signal("hotbar2_items", $Inventory_gui/GridContainer2/hotbar2.item)
	
	for i in range(0,6):
		if inventory_vector[i] != "None":
			var item = ItemClass.instance()
			item.define_item(inventory_vector[i])
			inventory_slots[i].putIntoSlot(item)
	for i in range(6,8):
		if inventory_vector[i] != "None":
			var item = ItemClass.instance()
			item.define_item(inventory_vector[i])
			hotbar_slots[i].putIntoSlot(item)	

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
				last_slot = slot
				slot.pickFromSlot()
				holding_item.global_position.x = get_global_mouse_position().x-64
				holding_item.global_position.y = get_global_mouse_position().y-64

func hotbar1_gui_input(event: InputEvent, slot: SlotClass):
	var last_item = slot.item
	slot_gui_input(event, slot)
	if last_item != slot.item:
		emit_signal("hotbar1_items", slot.item)

func hotbar2_gui_input(event: InputEvent, slot: SlotClass):
	var last_item = slot.item
	slot_gui_input(event, slot)
	if last_item != slot.item:
		emit_signal("hotbar2_items", slot.item)

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

func _on_HotBar_item_used(slot):
	hotbar_slots[slot].deleteItem()
	if player.life + 50 > 100:
		player.life = 100
	else:
		player.life += 50
	if slot == 0:
		emit_signal("hotbar1_items", null)
	else:
		emit_signal("hotbar2_items", null)

func loot(item):
	var new_item
	print(item)
	for i in range(0,6):
		if inventory_slots[i].item == null:
			new_item = ItemClass.instance()
			new_item.define_item(item)
			inventory_slots[i].putIntoSlot(new_item)
			return 0
	for i in range(0,2):
		if hotbar_slots[i].item == null:
			new_item = ItemClass.instance()
			new_item.define_item(item)
			hotbar_slots[i].putIntoSlot(new_item)
			if i == 0:
				emit_signal("hotbar1_items", $Inventory_gui/GridContainer2/hotbar1.item)
			else:
				emit_signal("hotbar2_items", $Inventory_gui/GridContainer2/hotbar2.item)
			return 0
	return 1

func _on_life_potion_(item, node):
	if loot(item) == 0:
		node.queue_free()

func _on_Chaos_longsword_pickup(item, node):
	if loot(item) == 0:
		node.queue_free()


func _on_Steel_longsword_pickup(item, node):
	if loot(item) == 0:
		node.queue_free()


func _on_key_pickup(item, node):
	if loot(item) == 0:
		node.queue_free()
