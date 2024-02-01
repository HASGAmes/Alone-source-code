
@icon("res://assets/resources/resource_icons/entity_icon.svg")
## This is the base for all interactive parts of my roguelike.
class_name Entity
extends Sprite2D

enum AIType {NONE, HOSTILE,PREY,PREDATOR,TURRET}##controls the ai of a entity
enum EntityType {CORPSE, ITEM, ACTOR}##decides if it is a corpse item or actor
enum MOVEMENT_TYPE{WALK,CROUCH,PRONE,SPRINT}##affects the movement mode
var entity_types:Dictionary## all of the entity types are loaded on launch
var item_path:String = "res://assets/definitions/entities/items/"
var actor_path:String = "res://assets/definitions/entities/actors/"
var blurb:String## used to make this entities description
var key: String##takes from entity types to load a entity
var current_movement:MOVEMENT_TYPE##current movement mode
@onready var dicebag = Dicebag.new()## is used for rolling for stuff
##is the position of a entity
var grid_position: Vector2i:
	set(value):
		grid_position = value
		global_position = Grid.grid_to_world(grid_position)
var _definition: EntityDefinition##loads a entity definition to get stuff like sprites,stats,etc
var entity_name: String## is the name of a entity
var blocks_movement: bool##if true you or other entities cannot walk or normally be on the same tile as this entity
## this uses the EntityType Enum to set the z level going to Corpse:1 Item:2 Actor:3
var type: EntityType:
	set(value):
		type = value
		z_index = type
var map_data: MapData##lets a entity access mapdata functions
var texture_size:Vector2i##the size of a current texture. unused for now
#components
var current_statuses:Array[StatusBase]##these are the current status effects on a entity
var fighter_component: FighterComponent##the component for effecting fighting stats
var ai_component: BaseAIComponent##determines the ai of a entity
var consumable_component: ConsumableComponent##if a item like a potion is used it has this on it
var inventory_component: InventoryComponent## controls the inventory of a entity. must have at least one slot to carry
var equipment_component :EquipmentComponent## controls the equipment which is based on the fightingcomponents bodyplan
var equipment_item_component:EquipmentItemComponent##this effects a entity's stats when equiped
var skill_component:SkillComponent##this used for using skills
var status_tracker:Node##tracks the skills of a entity
var part_effect:GPUParticles2D##used for particles
var collision = preload("res://assets/resources/raycast_body.tscn")
var turns_hunger:int = 0
var hunger:HungryDefinition = preload("res://assets/definitions/status_effects/hungerstage1.tres")
##sets up a entity. mapdata, start position and the key is needed to make one without problems
func _init(map_data: MapData, start_position: Vector2i, key: String = "") -> void:
	centered = false
	if SignalBus.actor_types.is_empty():
		update_keys(actor_path)
	else:
		entity_types.merge(SignalBus.actor_types)
	if SignalBus.item_types.is_empty():
		update_keys(item_path)
	else:
		entity_types.merge(SignalBus.item_types)
	
	grid_position = start_position
	self.map_data = map_data
	if key != "":
		set_entity_type(key)
## originally i had to add them one at a time but this just does it for me. note that if you want to
## spawn a entity it has to be as it is shown in the files.It isn't case sensitive
## in the case of the level editor however it needs to match the entity name 
func update_keys(path:String):
	var dir = DirAccess
	dir.open(path)
	var current:String
	var first:Array= dir.get_files_at(path)
	var merge_actor:bool = false
	var merge_item:bool = false
	if SignalBus.actor_types.is_empty():
		merge_actor = true
	elif SignalBus.item_types.is_empty():
		merge_item = true
	while !first.is_empty():
		current = first.pop_front()
		if current.ends_with(".remap"):
			current= current.trim_suffix(".remap")
			print(current)
		var dict:Dictionary ={current.left(current.length()-5).to_lower():path+current}
		entity_types.merge(dict)
		if merge_actor == true:
			SignalBus.actor_types.merge(entity_types)
		elif merge_item == true:
			SignalBus.item_types.merge(entity_types)
		#print(entity_types)
##sets the entity type with a string which coresponds with the dict with the list of entities. will cause a error if it either doesn't have a string or has the wrong one 
func set_entity_type(key: String) -> void:
	self.key = key.trim_suffix(".remap")
	var entity_definition: EntityDefinition = load(entity_types[self.key])
	
	_definition = entity_definition
	collision = collision.instantiate()
	add_child(collision)
	collision.position = Vector2i(8,8)
	collision.set_collision_layer(8)
	if entity_definition!= null:
		_definition = entity_definition
	type = _definition.type
	blurb = entity_definition.entity_blurb
	current_movement = entity_definition.starting_movement
	blocks_movement = _definition.is_blocking_movment
	entity_name = _definition.name
	texture = entity_definition.texture
	texture_size = texture.get_size()
	modulate = entity_definition.color
	status_tracker = Node.new()
	part_effect = GPUParticles2D.new()
	add_child(part_effect)
	add_child(status_tracker)
	part_effect.position += Vector2(8,-8)
	
	if entity_definition.item_definition is EquipmentDefinition:
		equipment_item_component = EquipmentItemComponent.new(entity_definition.item_definition)
		add_child(equipment_item_component)
	if entity_definition.item_definition is ConsumableComponentDefinition:
		_handle_consumable(entity_definition.item_definition)
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
		AIType.TURRET:
			ai_component = TurretAi.new()
			add_child(ai_component)
	if entity_definition.fighter_definition:
		fighter_component = FighterComponent.new(entity_definition.fighter_definition)
		add_child(fighter_component)
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


## moves a entity using the offset
func move(move_offset: Vector2i) -> void:
	map_data.unregister_blocking_entity(self)
	grid_position += move_offset
	map_data.register_blocking_entity(self)
	if map_data.get_tile(grid_position) == null:
		grid_position = Vector2i(0,0)
	visible = map_data.get_tile(grid_position).is_in_view
	
## if a entity is knocked back by something it uses the knockvec to 
##decided the direction and the knockbackforce to move one by one till it hits something
##or runs out of knockbackforce if it does hit a wall if there is enough force it goes through taking 1d6 damage otherwise
## it takes damage 1d6 times the leftover knockback force
## if it hits another alive entity they both start getting knocked back
func knockback(knockvec: Vector2i,knockbackforce) -> void:
	var destination = grid_position+knockvec*-1
	var destination_entity: Entity = map_data.get_actor_at_location(destination)
	var destination_tile: Tile = map_data.get_tile(destination)
	map_data.unregister_blocking_entity(self)
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
						if destination_entity.is_alive():
							var  attack_description: String = "%s crashes into a wall!!!" % [destination_entity.get_entity_name()]
							var crashingdam= dicebag.roll_dice(knockbackforce,6,0)
							var crit:Color
							crit = GameColors.CRIT
							destination_entity.fighter_component.take_damage(crashingdam,[DamageTypes.DAMAGE_TYPES.BLUDGEONING],attack_description)
							knockbackforce-=1
					if is_alive():
						var  attack_description: String = "%s crashes into the %s!!!" % [get_entity_name(),destination_entity.get_entity_name()]
						var crashingdam= randi_range(1,6)*knockbackforce
						var crit:Color
						crit = GameColors.CRIT
						destination_entity.fighter_component.take_damage(crashingdam,[DamageTypes.DAMAGE_TYPES.BLUDGEONING],attack_description)
						knockbackforce-=1
						continue
		else:
			if not destination_tile.is_walkable():
				if destination_tile.is_destructible() and destination_tile.defense<=knockbackforce*5:
					if ai_component !=null:
						var attack_description: String = "%s crashes into a wall!!!" % [get_entity_name()]
						var crashingdam= randi_range(1,6)
						var crit:Color
						crit = GameColors.CRIT
						fighter_component.take_damage(crashingdam,[DamageTypes.DAMAGE_TYPES.BLUDGEONING],attack_description)
						knockbackforce -= 1
						destination_tile.hp = 0
						continue
		knockbackforce-=1
	map_data.register_blocking_entity(self)
	if map_data.get_tile(grid_position) == null:
		grid_position = Vector2i(1,1)
	visible = map_data.get_tile(grid_position).is_in_view
	fighter_component.quickness = orginal_quickness
## is used to get the distance of two entities
func distance(other_position: Vector2i) -> int:
	var distance_x = other_position.x-grid_position.x
	var distance_y = other_position.y-grid_position.y
	if distance_x<0:
		distance_x*=-1
	if distance_y<0:
		distance_y*=-1
	var distance:int
	if distance_x>distance_y:
		distance = distance_x
	if distance_y>distance_x:
		distance = distance_y
	if distance_x == distance_y:
		distance=distance_x
	return distance
##returns whether or not a entity is blocking movement
func is_blocking_movement() -> bool:
	return blocks_movement

##returns a entity's name
func get_entity_name() -> String:
	return entity_name

##returns a entity's type like if it is a corpse, item or actor
func get_entity_type() -> int:
	return _definition.type

## returns if it is alive. might seem more obvious to use hp but not every entity has the fight component but the ones that do lose their ai on death and every entity has a ai component so this works best unless i want items to be destructible later
func is_alive() -> bool:
	return ai_component != null
##runs everytime a turn is passed to trigger effects for status effects
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
	if fighter_component.hunger <= 0 and fighter_component.hp >=1:
		add_status([hunger])
	while !status.is_empty():
		var current_status= status.pop_front()
		current_status.activate_effect(self)
	var skill = fighter_component.skill_tracker.get_children().duplicate()
	while !skill.is_empty():
		var currentskill = skill.pop_front()
		if currentskill.tick_cooldown != currentskill.cooldown:
			currentskill.tick_cooldown+=1
	
## decides what kind of consumable a entity is based on the attached consumable component. there is a id on each one that says it is that type which is what this function uses to filter them.
func _handle_consumable(consumable_definition: ConsumableComponentDefinition) -> void:
	if consumable_definition!=null:
		consumable_component = consumable_definition.item_id.new(consumable_definition)
	if consumable_component:
		add_child(consumable_component)
## if a entity isn't hostile if you move to the same tile you swap places
func swap(swap_target:Entity , swapper:Vector2i = grid_position):
	map_data.unregister_blocking_entity(self)
	map_data.unregister_blocking_entity(swap_target)
	var target_swap:Vector2i = swap_target.grid_position
	self.grid_position = target_swap
	swap_target.grid_position = swapper
	map_data.register_blocking_entity(self)
	map_data.register_blocking_entity(swap_target)
## adds a status effect. it takes the status id and uses that to give the right one. also they have chances to proc if it isn't high enough you don't get the status. if it is 100 you will always get it
## also if a effect can stack you can get a unlimited amount but if not if you already have one you won't get another
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
## uses a json file to read data to get the x,y, and key as well as all the components which runs their own get save func
func get_save_data() -> Dictionary:
	var save_data: Dictionary = {
		"x": grid_position.x,
		"y": grid_position.y,
		"key": key,
	}
	if fighter_component:
		save_data["fighter_component"] = fighter_component.get_save_data()
	if ai_component:
		save_data["ai_component"] = ai_component.get_save_data()
	if inventory_component:
		save_data["inventory_component"] = inventory_component.get_save_data()
	return save_data
## using save data restores to a previous save point
func restore(save_data: Dictionary) -> void:
	grid_position = Vector2i(save_data["x"], save_data["y"])
	set_entity_type(save_data["key"])
	if fighter_component and save_data.has("fighter_component"):
		fighter_component.restore(save_data["fighter_component"])
	if ai_component and save_data.has("ai_component"):
		var ai_data: Dictionary = save_data["ai_component"]
		if ai_data["type"] == "ConfusedEnemyAIComponent":
			var confused_enemy_ai := ConfusedEnemyAIComponent.new(ai_data["turns_remaining"])
			add_child(confused_enemy_ai)
	if inventory_component and save_data.has("inventory_component"):
		inventory_component.restore(save_data["inventory_component"])
