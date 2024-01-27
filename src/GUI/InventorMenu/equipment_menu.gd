class_name EquipmentMenu
extends CanvasLayer

signal equipment_selected(slot)

@onready var inventory_menu_item_scene= preload("res://src/GUI/InventorMenu/inventory_menu_item.tscn")

@onready var inventory_list: VBoxContainer = $"%InventoryList"
@onready var title_label: Label = $"%TitleLabel"
func _ready() -> void:
	hide()


func build(title_text: String, Equipment_slots: EquipmentComponent) -> void:
#	if !Equipment_slots.slots:
#		button_pressed.call_deferred()
#		MessageLog.send_message("No equipment slots somehow in inventory. This should be impossible", GameColors.IMPOSSIBLE)
#		equipment_selected.emit(null)
#		return
	title_label.text = title_text
	var slots =Equipment_slots.body.duplicate()
	var slot = -1
	while !slots.is_empty():
		slot+=1
		var current_slot = slots.pop_front()
		_register_item(slot,current_slot,current_slot.equiped_item)
	inventory_list.get_child(0).grab_focus()
	show()


func _register_item(index: int, slot: Limb_Component, item:Entity = null) -> void:
	var item_button: Button = inventory_menu_item_scene.instantiate()
	var char: String = String.chr("a".unicode_at(0) + index)
	item_button.current_limb = slot
	if item!=null:
		item_button.icon = item.texture
		var weapon_dice = slot.equiped_item.equipment_item_component.damage_dice.duplicate()
		var weapon_text= " %sd%s"%[weapon_dice.pop_front(),weapon_dice.pop_front()]
		item_button.add_theme_color_override("icon_normal_color",item.modulate)
		item_button.add_theme_color_override("icon_focus_color",item.modulate)
		var button_text = slot.name_limb+ "( "+item.get_entity_name()+" )"
		item_button.text = "( %s ) %s" % [char,button_text ]
		item_button.text+=weapon_text
	else:
		var weapon_dice = slot.damage_dice.duplicate()
		var weapon_text= " %sd%s"%[weapon_dice.pop_front(),weapon_dice.pop_front()]
		item_button.text = "( %s ) %s" % [char, slot.name_limb]
		if slot.natural_weapon == true:
			item_button.text+=weapon_text
	var fight:FighterComponent = SignalBus.player.fighter_component
	if item_button.current_limb == fight.current_primary_limb: 
		item_button.text +="/"
	if item_button.text.ends_with("/") and item_button.current_limb!= fight.current_primary_limb:
		item_button.text.erase(item_button.text.length()-1,1)
	var shortcut_event := InputEventKey.new()
	shortcut_event.keycode = KEY_A + index
	item_button.shortcut = Shortcut.new()
	item_button.shortcut.events = [shortcut_event]
	item_button.pressed.connect(button_pressed.bind(slot))
	inventory_list.add_child(item_button)
func update_button(index:int,item_button:BaseButton, slot: Limb_Component, item:Entity = null)->void:
	var char: String = String.chr("a".unicode_at(0) + index)
	item_button.current_limb = slot
	if item!=null:
		item_button.icon = item.texture
		var weapon_dice = slot.equiped_item.equipment_item_component.damage_dice.duplicate()
		var weapon_text= " %sd%s"%[weapon_dice.pop_front(),weapon_dice.pop_front()]
		item_button.add_theme_color_override("icon_normal_color",item.modulate)
		item_button.add_theme_color_override("icon_focus_color",item.modulate)
		var button_text = slot.name_limb+ "( "+item.get_entity_name()+" )"
		item_button.text = "( %s ) %s" % [char,button_text ]
		item_button.text+=weapon_text
	else:
		var weapon_dice = slot.damage_dice.duplicate()
		var weapon_text= " %sd%s"%[weapon_dice.pop_front(),weapon_dice.pop_front()]
		item_button.text = "( %s ) %s" % [char, slot.name_limb]
		if slot.natural_weapon == true:
			item_button.text+=weapon_text
	var fight:FighterComponent = SignalBus.player.fighter_component
	if item_button.current_limb == fight.current_primary_limb: 
		item_button.text +="/"
	if item_button.text.ends_with("/") and item_button.current_limb!= fight.current_primary_limb:
		item_button.text.erase(item_button.text.length()-1,1)

func _physics_process(_delta: float) -> void:
	var fight:FighterComponent = SignalBus.player.fighter_component
	if Input.is_action_just_pressed("select_attacking_limb"):
		var button = inventory_list.get_children()
		var limb:Limb_Component
		var slots:Array[Node] =fight.body_plan.get_children()
		var slot = -1
		
		while button.size() >1:
			var current_button:Button = button.pop_front()
			if current_button.has_focus():
				limb = current_button.current_limb
				print(current_button.current_limb.equiped_item,limb.name_limb)
				if !current_button.text.ends_with("/"):
					current_button.text +="/"
			elif current_button.text.ends_with("/"):
				current_button.text.erase(current_button.text.length()-1,1)
		button = inventory_list.get_children()
		while !slots.is_empty():
			var current_button:Button = button.pop_front()
			slot+=1
			var current_slot = slots.pop_front()
			update_button(slot,current_button,current_slot,current_slot.equiped_item)
		SignalBus.player.fighter_component.set_attacking_limbs(null,limb)

	if Input.is_action_just_pressed("ui_back"):
		equipment_selected.emit(null)
		queue_free()


func button_pressed(slot:Limb_Component = null) -> void:
	equipment_selected.emit(slot)
	queue_free()
