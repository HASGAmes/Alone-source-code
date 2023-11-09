class_name Entity
extends Sprite2D

enum AIType {NONE, HOSTILE,PREY,PREDATOR}
enum EntityType {CORPSE, ITEM, ACTOR}
enum MOVEMENT_TYPE{WALK,CROUCH,PRONE,SPRINT}
var current_movement:MOVEMENT_TYPE
@onready var dicebag = Dicebag.new()
var grid_position: Vector2i:
	set(value):
		grid_position = value
		position = Grid.grid_to_world(grid_position)
var _definition: EntityDefinition
var entity_name: String
var blocks_movement: bool
var type: EntityType:
	set(value):
		type = value
		z_index = type
var map_data: MapData
var texture_size:Vector2i
#components
var current_statuses:Array[StatusBase]
var fighter_component: FighterComponent
var ai_component: BaseAIComponent
var consumable_component: ConsumableComponent
var inventory_component: InventoryComponent
var equipment_component :EquipmentComponent
var skill_component:SkillComponent
#####
var status_tracker:Node
var part_effect:GPUParticles2D
var turns_hunger:int = 0
func _init(map_data: MapData, start_position: Vector2i, entity_definition: EntityDefinition) -> void:
	centered = false
	grid_position = start_position
	self.map_data = map_data
	set_entity_type(entity_definition)


func set_entity_type(entity_definition: EntityDefinition) -> void:
	
	if entity_definition!= null:
		_definition = entity_definition
	type = _definition.type
	current_movement = entity_definition.starting_movement
	blocks_movement = _definition.is_blocking_movment
	entity_name = _definition.name
	texture = entity_definition.texture
	texture_size = texture.get_size()
	print(texture_size)
	modulate = entity_definition.color
	status_tracker = Node.new()
	part_effect = GPUParticles2D.new()
	add_child(part_effect)
	add_child(status_tracker)
	part_effect.position += Vector2(8,-8)
	match entity_definition.ai_type:
		AIType.NONE:
			ai_component = null
		AIType.HOSTILE:
			ai_component = HostileEnemyAIComponent.new()
			add_child(ai_component)
		AIType.PREY:
			ai_component = PreyAi.new()
			add_child(ai_component)
		AIType.PREDATOR:
			ai_component = PredatorAi.new()
			add_child(ai_component)
	if entity_definition.fighter_definition:
		fighter_component = FighterComponent.new(entity_definition.fighter_definition)
		add_child(fighter_component)
		
	if entity_definition.consumable_definition:
		_handle_consumable(entity_definition.consumable_definition)
	if entity_definition.inventory_capacity > 0:
		inventory_component = InventoryComponent.new(entity_definition.inventory_capacity)
		add_child(inventory_component)
	if fighter_component:
		equipment_component = EquipmentComponent.new(fighter_component.body_plan)
		add_child(equipment_component)
		skill_component = SkillComponent.new(fighter_component)
		add_child(skill_component)
	if entity_definition.starting_status:
		var status = entity_definition.starting_status.duplicate()
		add_status(status)



func move(move_offset: Vector2i) -> void:
	map_data.unregister_blocking_entity(self)
	grid_position += move_offset
	map_data.register_blocking_entity(self)
	if map_data.get_tile(grid_position) == null:
		grid_position = Vector2i(0,0)
	visible = map_data.get_tile(grid_position).is_in_view
	

func knockback(knockvec: Vector2i,knockbackforce) -> void:
	map_data.unregister_blocking_entity(self)
	var destination = grid_position+knockvec*-1
	var destination_entity: Entity = map_data.get_actor_at_location(destination)
	var destination_tile: Tile = map_data.get_tile(destination)
	var orginal_quickness = fighter_component.quickness
	while knockbackforce>0:
		fighter_component.quickness = 0
		if destination_tile == null or destination_tile.is_walkable():
			if destination_entity ==null or not destination_entity.is_blocking_movement():
				grid_position+= knockvec*-1
				destination=grid_position+knockvec*-1
				destination_entity =map_data.get_actor_at_location(destination)
				destination_tile=map_data.get_tile(destination)
			else:
				if destination_entity.is_blocking_movement():
					var entityknockedbacktile: Tile = map_data.get_tile(destination_entity.grid_position+knockvec*-1)
					if entityknockedbacktile.is_walkable() or entityknockedbacktile == null:
						destination_entity.knockback(knockvec,knockbackforce)
					else:
						if destination_entity.ai_component !=null:
							var  attack_description: String = "%s crashes into a wall!!!" % [destination_entity.get_entity_name()]
							var crashingdam= dicebag.roll_dice(knockbackforce,6,0)
							var crit:Color
							crit = GameColors.CRIT
							attack_description += " and takes %d damage." % crashingdam
							destination_entity.fighter_component.hp -= crashingdam
							MessageLog.send_message(attack_description, crit)
							knockbackforce-=1
					if ai_component !=null:
						var  attack_description: String = "%s crashes into a %s!!!" % [get_entity_name(),destination_entity.get_entity_name()]
						var crashingdam= randi_range(1,6)*knockbackforce
						var crit:Color
						crit = GameColors.CRIT
						attack_description += " and takes %d damage." % crashingdam
						fighter_component.hp -= crashingdam
						MessageLog.send_message(attack_description, crit)
						knockbackforce-=1
						continue
		else:
			if not destination_tile.is_walkable():
				if destination_tile.is_destructible() and destination_tile.defense<=knockbackforce*5:
					destination_tile.hp = 0
					print("yes")
					if ai_component !=null:
						var  attack_description: String = "%s crashes into a wall!!!" % [get_entity_name()]
						var crashingdam= randi_range(1,6)
						var crit:Color
						crit = GameColors.CRIT
						attack_description += " and takes %d damage." % crashingdam
						fighter_component.hp -= crashingdam
						MessageLog.send_message(attack_description, crit)
						knockbackforce -= 1
						continue
		knockbackforce-=1
	map_data.register_blocking_entity(self)

	if map_data.get_tile(grid_position) == null:
		grid_position = Vector2i(40,40)
	visible = map_data.get_tile(grid_position).is_in_view
	fighter_component.quickness = orginal_quickness

func distance(other_position: Vector2i) -> float:
	var relative: Vector2i = other_position - grid_position
	return relative.length()


func is_blocking_movement() -> bool:
	return blocks_movement


func get_entity_name() -> String:
	return entity_name


func get_entity_type() -> int:
	return _definition.type


func is_alive() -> bool:
	return ai_component != null
func passed_turn():
	if fighter_component.turns_not_in_combat>=10 and fighter_component.hp >=1:
		fighter_component.passively_heal()
	var status =status_tracker.get_children()
	var hunger_dice = dicebag.roll_dice(1,20,0)
	if hunger_dice ==1 and turns_hunger<10:
		fighter_component.hunger -= 1
	else:
		turns_hunger+=1
	if turns_hunger >=10:
		hunger_dice = dicebag.roll_special_dice(20,false,2)
		if hunger_dice <=2:
			fighter_component.hunger -=2
			turns_hunger = 0
	if fighter_component.hunger == 0 and fighter_component.hp >=1:
		fighter_component.take_damage(1,DamageTypes.DAMAGE_TYPES.INTERNAL)
	while !status.is_empty():
		var current_status= status.pop_front()
		current_status.activate_effect(self)
	var skill = fighter_component.skill_tracker.get_children().duplicate()
	while !skill.is_empty():
		var currentskill = skill.pop_front()
		if currentskill.tick_cooldown != currentskill.cooldown:
			currentskill.tick_cooldown+=1
	
func _handle_consumable(consumable_definition: ConsumableComponentDefinition) -> void:
	consumable_component = consumable_definition.item_id.new(consumable_definition)
	if consumable_component:
		add_child(consumable_component)

func swap(swap_target:Entity , swapper:Vector2i = grid_position):
	map_data.unregister_blocking_entity(self)
	map_data.unregister_blocking_entity(swap_target)
	var target_swap:Vector2i = swap_target.grid_position
	self.grid_position = target_swap
	swap_target.grid_position = swapper
	map_data.register_blocking_entity(self)
	map_data.register_blocking_entity(swap_target)
func add_status(starting_status:Array[StatusEffectDefinition]) ->void:
	while !starting_status.is_empty():
		var status =starting_status.pop_front()
		var current_status:StatusBase
		current_status = status.status_id.new(status)
		var proc = randi_range(1,100)
		if status.can_stack == false:
			if status_tracker.get_children(status.can_stack):
				return
		if proc <= status.proc_chance:
			status_tracker.add_child(current_status)
		print(status)
