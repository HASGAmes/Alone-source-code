extends BaseInputHandler

const directions = {
	"move_up": Vector2i.UP,
	"move_down": Vector2i.DOWN,
	"move_left": Vector2i.LEFT,
	"move_right": Vector2i.RIGHT,
	"move_up_left": Vector2i.UP + Vector2i.LEFT,
	"move_up_right": Vector2i.UP + Vector2i.RIGHT,
	"move_down_left": Vector2i.DOWN + Vector2i.LEFT,
	"move_down_right": Vector2i.DOWN + Vector2i.RIGHT,
}

const inventory_menu_scene = preload("res://src/GUI/InventorMenu/inventory_menu.tscn")
const equipment_menu_scene = preload("res://src/GUI/InventorMenu/equipment_menu.tscn")
const skill_menu_scene = preload("res://src/GUI/InventorMenu/skill_menu.tscn")
@export var reticle: Reticle
@onready var timer = $input_delay
var pressed 
func get_action(player: Entity) -> Action:
	var action: Action = null
	if $input_delay.is_stopped():
		for direction in directions:
			if Input.is_action_just_pressed(direction):
				pressed = true
			if Input.is_action_pressed(direction) and pressed == true:
				var offset: Vector2i = directions[direction]
				print(offset)
				action = BumpAction.new(player, offset.x, offset.y)
				$input_delay.start()
		if Input.is_action_pressed("wait"):
			action = WaitAction.new(player)
			$input_delay.start()
	for direction in directions:
		if Input.is_action_just_released(direction):
			pressed = null
			$input_delay.stop()
	if Input.is_action_just_pressed("COMMAND_LINE"):
		get_parent().transition_to(InputHandler.InputHandlers.DUMMY)
	if Input.is_action_just_pressed("ranged_attack"):
		action = await ranged_attack(player)
	if Input.is_action_just_pressed("force_melee"):
		action =  await melee_direction(player)
	if Input.is_action_just_pressed("view_history"):
		get_parent().transition_to(InputHandler.InputHandlers.HISTORY_VIEWER)
	
	if Input.is_action_just_pressed("pickup"):
		action = PickupAction.new(player)
	
	if Input.is_action_just_pressed("drop"):
		if !player.inventory_component.items.is_empty():
			var selected_item: Entity = await get_item("Select an item to drop", player.inventory_component)
			action = DropItemAction.new(player, selected_item)
			get_parent().transition_to(InputHandler.InputHandlers.MAIN_GAME) 
		else :
			MessageLog.send_message("Your pockets are already empty",GameColors.INVALID)
	if Input.is_action_just_pressed("equipment_action"):
		player.equipment_component.update_slots(player.fighter_component.body_plan)
		action = await change_equipment(player)
		get_parent().transition_to(InputHandler.InputHandlers.MAIN_GAME) 
		
	if Input.is_action_just_pressed("activate"):
		if !player.inventory_component.items.is_empty():
			action = await activate_item(player)
			get_parent().transition_to(InputHandler.InputHandlers.MAIN_GAME) 
		else :
			MessageLog.send_message("Your pockets are empty",GameColors.INVALID)
	if Input.is_action_just_pressed("look"):
		await get_grid_position(player, 0,true)
	
	if Input.is_action_just_pressed("skill_menu"):
		player.skill_component.update_slots(player.fighter_component)
		action = await activate_skill(player)
		get_parent().transition_to(InputHandler.InputHandlers.MAIN_GAME) 
	if Input.is_action_just_pressed("quit"):
		action = EscapeAction.new(player)
	
	return action
func ranged_attack(player: Entity) -> Action:
	var target = await get_grid_position(player,0,true)
	if target == Vector2i(0,0):
		return
	return RangedAction.new(player,target)
func activate_skill(player: Entity) -> Action:
	var selected_item: Skills = await get_skills("Select a skill to use",player.skill_component,player)
	if selected_item == null:
		return null
	var target_radius: int = selected_item.range
	var target_position: Vector2i
	if selected_item.skill_buff== true:
		target_position = player.grid_position
	else:
		target_position= await get_grid_position(player, target_radius,selected_item.free_move,true)
	if target_position == Vector2i(0, 0):
		return null
	if selected_item.tick_cooldown!=selected_item.cooldown:
		MessageLog.send_message("Skill not off cooldown",GameColors.INVALID)
		return
	return SkillAction.new(player,selected_item,player.map_data,target_position)
func activate_item(player: Entity) -> Action:
	var selected_item: Entity = await get_item("Select an item to use", player.inventory_component)
	if selected_item == null:
		get_parent().transition_to(InputHandler.InputHandlers.MAIN_GAME)
		return null
	var target_radius: int = -1
	if selected_item.consumable_component != null:
		target_radius = selected_item.consumable_component.get_targeting_radius()
	if target_radius == -1:
		return ItemAction.new(player, selected_item)
	
	var target_position: Vector2i = await get_grid_position(player, target_radius,true)
	if target_position == Vector2i(-1, -1):
		return null
	return ItemAction.new(player, selected_item, target_position)
func change_equipment(player: Entity) -> Action:
	
	var selected_limb: Limb_Component = await get_equipment("List of equipment", player.equipment_component,player)
	if selected_limb == null:
		get_parent().transition_to(InputHandler.InputHandlers.MAIN_GAME)
		return null
	var selected_item = await get_item("Select an item to equip", player.inventory_component)
	if selected_item.equipment_item_component == null:
		get_parent().transition_to(InputHandler.InputHandlers.MAIN_GAME)
		return null
	if selected_item.equipment_item_component.equipment_slot!= selected_limb.limb_type:
		get_parent().transition_to(InputHandler.InputHandlers.MAIN_GAME)
		return null
	return Equip_Action.new(player,selected_limb,selected_item)
func get_item(window_title: String, inventory: InventoryComponent) -> Entity:
	var inventory_menu: InventoryMenu = inventory_menu_scene.instantiate()
	add_child(inventory_menu)
	inventory_menu.build(window_title, inventory)
	get_parent().transition_to(InputHandler.InputHandlers.DUMMY)
	var selected_item: Entity = await inventory_menu.item_selected
	if selected_item == null:
		await get_tree().physics_frame
		get_parent().call_deferred("transition_to", InputHandler.InputHandlers.MAIN_GAME)
	return selected_item
func melee_direction(player: Entity) -> Action:
	var target_position: Vector2i = await get_grid_position(player, 1,false)
	print(target_position)
	if target_position == Vector2i.ZERO:
		return 
	return MeleeAction.new(player, target_position.x, target_position.y)
func get_equipment(window_title: String, equipment: EquipmentComponent,player:Entity) -> Limb_Component:
	var equipment_menu: EquipmentMenu = equipment_menu_scene.instantiate()
	add_child(equipment_menu)
	equipment_menu.build(window_title,equipment)
	get_parent().transition_to(InputHandler.InputHandlers.DUMMY)
	var fight :FighterComponent= player.fighter_component
	var selected_equipment: Limb_Component = await equipment_menu.equipment_selected
	if Input.is_action_just_pressed("select_attacking_limb") and selected_equipment.natural_weapon == true:
		fight.current_weapon_dice = selected_equipment.damage_dice
		fight.current_weapon_side_dice = selected_equipment.damage_sides
	#print(selected_equipment.natural_weapon)
	return selected_equipment
func get_skills(window_title: String, skill: SkillComponent,player:Entity) -> Skills:
	var skill_menu: SkillMenu = skill_menu_scene.instantiate()
	add_child(skill_menu)
	skill_menu.build(window_title,player.fighter_component)
	get_parent().transition_to(InputHandler.InputHandlers.DUMMY)
	var fight :FighterComponent= player.fighter_component
	var selected_skill: Skills = await skill_menu.skill_selected
	#print(selected_equipment.natural_weapon)
	return selected_skill
func get_grid_position(player: Entity, radius: int,freemove:bool,stayinrange:bool = false) -> Vector2i:
	get_parent().transition_to(InputHandler.InputHandlers.DUMMY)
	var selected_position = await reticle.select_position(player, radius,freemove,stayinrange)
	print(selected_position)
	await get_tree().physics_frame
	get_parent().call_deferred("transition_to", InputHandler.InputHandlers.MAIN_GAME)
	return selected_position


func _on_input_delay_timeout():
	pass # Replace with function body.
