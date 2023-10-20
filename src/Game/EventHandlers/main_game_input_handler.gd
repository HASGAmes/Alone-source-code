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
@export var reticle: Reticle


func get_action(player: Entity) -> Action:
	var action: Action = null
	if $input_delay.is_stopped():
		for direction in directions:
			if Input.is_action_pressed(direction):
				var offset: Vector2i = directions[direction]
				print(offset)
				action = BumpAction.new(player, offset.x, offset.y)
				$input_delay.start()
		if Input.is_action_just_pressed("COMMAND_LINE"):
			get_parent().transition_to(InputHandler.InputHandlers.DUMMY)
		if Input.is_action_just_pressed("wait"):
			action = WaitAction.new(player)
		
		if Input.is_action_just_pressed("view_history"):
			get_parent().transition_to(InputHandler.InputHandlers.HISTORY_VIEWER)
		
		if Input.is_action_just_pressed("pickup"):
			action = PickupAction.new(player)
		
		if Input.is_action_just_pressed("drop"):
			if !player.inventory_component.items.is_empty():
				var selected_item: Entity = await get_item("Select an item to drop", player.inventory_component)
				action = DropItemAction.new(player, selected_item)
			else :
				MessageLog.send_message("Your pockets are already empty",GameColors.INVALID)
		if Input.is_action_just_pressed("equipment_action"):
			action = await change_equipment(player)
			
		if Input.is_action_just_pressed("activate"):
			if !player.inventory_component.items.is_empty():
				action = await activate_item(player)
			else :
				MessageLog.send_message("Your pockets are empty",GameColors.INVALID)
		if Input.is_action_just_pressed("look"):
			await get_grid_position(player, 0)
		
		if Input.is_action_just_pressed("toggle_mute"):
			action = await activate_skill(player)
		
		if Input.is_action_just_pressed("quit"):
			action = EscapeAction.new(player)
		
	return action

func activate_skill(player: Entity) -> Action:
	var selected_item: Skills = player.fighter_component.skill_tracker.get_child(0)
	if selected_item == null:
		return null
	var target_radius: int = -1
	if selected_item != null:
		target_radius = selected_item.get_targeting_radius()
	if target_radius == -1:
		return SkillAction.new(player,player.fighter_component.skill_tracker.get_child(0),player.grid_position)
	var target_position: Vector2i = await get_grid_position(player, target_radius)
	if target_position == Vector2i(-1, -1):
		return null
	return SkillAction.new(player,player.fighter_component.skill_tracker.get_child(0),target_position)
func activate_item(player: Entity) -> Action:
	var selected_item: Entity = await get_item("Select an item to use", player.inventory_component)
	if selected_item == null:
		return null
	var target_radius: int = -1
	if selected_item.consumable_component != null:
		target_radius = selected_item.consumable_component.get_targeting_radius()
	if target_radius == -1:
		return ItemAction.new(player, selected_item)
	var target_position: Vector2i = await get_grid_position(player, target_radius)
	if target_position == Vector2i(-1, -1):
		return null
	return ItemAction.new(player, selected_item, target_position)
func change_equipment(player: Entity) -> Action:
	var selected_item: Entity = await get_equipment("List of equipment", player.equipment_component)
	return ItemAction.new(player, selected_item)
func get_item(window_title: String, inventory: InventoryComponent) -> Entity:
	var inventory_menu: InventoryMenu = inventory_menu_scene.instantiate()
	add_child(inventory_menu)
	inventory_menu.build(window_title, inventory)
	get_parent().transition_to(InputHandler.InputHandlers.DUMMY)
	var selected_item: Entity = await inventory_menu.item_selected
	if selected_item and selected_item.consumable_component and selected_item.consumable_component.get_targeting_radius() == -1:
		await get_tree().physics_frame
		get_parent().call_deferred("transition_to", InputHandler.InputHandlers.MAIN_GAME)
	return selected_item

func get_equipment(window_title: String, equipment: EquipmentComponent) -> Entity:
	var equipment_menu: EquipmentMenu = equipment_menu_scene.instantiate()
	add_child(equipment_menu)
	equipment_menu.build(window_title,equipment)
	get_parent().transition_to(InputHandler.InputHandlers.DUMMY)
	var selected_equipment: Entity = await equipment_menu.equipment_selected
	if selected_equipment and selected_equipment.consumable_component and selected_equipment.consumable_component.get_targeting_radius() == -1:
		await get_tree().physics_frame
		get_parent().call_deferred("transition_to", InputHandler.InputHandlers.MAIN_GAME)
	return selected_equipment
	
func get_grid_position(player: Entity, radius: int) -> Vector2i:
	get_parent().transition_to(InputHandler.InputHandlers.DUMMY)
	var selected_position: Vector2i = await reticle.select_position(player, radius)
	await get_tree().physics_frame
	get_parent().call_deferred("transition_to", InputHandler.InputHandlers.MAIN_GAME)
	return selected_position


func _on_input_delay_timeout():
	pass # Replace with function body.
