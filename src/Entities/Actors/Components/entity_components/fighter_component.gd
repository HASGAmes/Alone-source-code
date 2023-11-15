class_name FighterComponent
extends Component

signal hp_changed(hp, max_hp)
signal hunger_changed(hunger,max_hunger)
var skill_tracker:Node
var turns_not_in_combat:int = 5
var max_hp: int
var hp: int:
	set(value):
		hp = clampi(value, 0, max_hp)
		hp_changed.emit(hp, max_hp)
		if hp <= 0:
			die()
var max_hunger: int
var hunger: int:
	set(value):
		hunger = clampi(value, 0, max_hunger)
		hunger_changed.emit(hunger, max_hunger)
######################
var strength_mod
var dex_mod
var toughness_mod
var wisdom_mod
######################
var defense: int
var hit_chance:int
var power: int
var critdam:int
var quickness:int#affects turn order
var decap
var turn:int#affects turn order
var DV: int #affects hit chance like ac in dnd
var str: int
var dex:int
var tough:int
var wis:int
var dismember_chance:int
var death_texture: Texture
var death_color: Color
var body_plan: Body_Plan
var death_sound: AudioStreamWAV
var healed_amount:float
var onhit_effects:Array[StatusEffectDefinition]
var current_weapon_dice:int
var current_weapon_side_dice:int
#####################
var xp:int
var lv:int =1
var credit_exp:Entity
var aggression:int
var res:Array
var immune:Array
var weakness:Array
var items_to_drop:Array[EntityDefinition]
var corpse_food:FoodConsumableDefinition

func _init(definition: FighterComponentDefinition) -> void:
	randomize()
	print(definition.skills)
	corpse_food = definition.corpse_food
	res = definition.res
	weakness = definition.weakness
	immune = definition.immunity
	items_to_drop = definition.items_on_death.duplicate()
	skill_tracker = Node.new()
	add_child(skill_tracker)
	aggression = definition.aggression
	onhit_effects = definition.on_hit_effects
	str = definition.str
	dex = definition.dex
	tough = definition.toughness
	wis = definition.will
	setup_mods()
	death_sound = definition.death_noise.pick_random()
	hit_chance = definition.hit_chance
	defense = definition.defense
	DV = definition.DV
	dismember_chance= definition.dismember_chance
	power = definition.power
	critdam = definition.critdam
	quickness = definition.quickness
	death_texture = definition.death_texture
	death_color = definition.death_color
	
	if definition.skills:
		add_skills(definition.skills.duplicate())
	
	max_hp = definition.max_hp+toughness_mod
	decap = definition.decap
	hp = max_hp
	max_hunger = definition.max_hunger
	hunger = max_hunger
	if definition.body_plan_definition:
		set_up_body(definition)
func level_up():
	var particle = preload("res://assets/resources/animations/levelup.tres")
	var texture = preload("res://assets/resources/animations/particleeffectstestericon.tres")
	var part = entity.part_effect
	part.process_material = particle
	part.amount = randi_range(10,20)
	part.texture = texture
	part.lifetime = 2.45
	part.speed_scale = 2.65
	part.explosiveness = 1
	part.emitting = true
	part.one_shot = true
	gain_random_stat(entity.dicebag.roll_dice(1,6,0))
	var add_health = entity.dicebag.roll_dice(1,8,toughness_mod)
	max_hp += add_health
	heal(add_health)
	lv +=1
	xp -= lv
	MessageLog.send_message("%s is now level:%x "%[entity.get_entity_name(),lv],GameColors.HEALTH_RECOVERED)
	if xp>= lv*2:
		level_up()
	
func set_up_body(definition:FighterComponentDefinition)->void:
	definition.body_plan_def = definition.body_plan_definition.duplicate()
	await entity != null
	body_plan = Body_Plan.new(definition.body_plan_def,entity)
	add_child(body_plan)
	body_plan.list_of_limbs = body_plan.list_of_limbs.duplicate()
	set_up_equipment(body_plan)
func set_up_equipment(body:Body_Plan)->void:
	var check_body = body.get_children().duplicate()
	while !check_body.is_empty():
		print("hm1")
		var limb_check:Limb_Component = check_body.pop_front()
		if limb_check.equiped_item_definition!=null and limb_check.equiped_item==null:
			print("hm2")
			limb_check.equiped_item = Entity.new(null,Vector2i(10,10),limb_check.equiped_item_definition)
func add_skills(listskills:Array[Skills_Definition])->void:
	while !listskills.is_empty():
		var current_skill =listskills.pop_front()
		var skill:Skills
		print(skill,"hmm")
		skill = current_skill.skill_id.new(current_skill)
		skill_tracker.add_child(skill)
		
func setup_mods()->void:
	strength_mod = str-9
	dex_mod = dex-9
	toughness_mod = tough-9
	wisdom_mod = wis-9
func _save_roll(challenge:int,mod:int) -> bool:
	var save_roll = entity.dicebag.roll_dice(1,20,mod)
	if save_roll>=challenge:
		return true
	else:
		return false
func heal(amount: int) -> int:
	if hp == max_hp:
		return 0
	
	var new_hp_value: int = hp + amount
	
	if new_hp_value > max_hp:
		new_hp_value = max_hp
		
	var amount_recovered: int = new_hp_value - hp
	hp = new_hp_value
	return amount_recovered


func take_damage(amount: int, damage_type:DamageTypes.DAMAGE_TYPES,damage_message:String) -> void:
	var imm = immune.duplicate()
	var resistance = res.duplicate()
	var weak = weakness.duplicate()
	var resistances_message:String = ""
	while !weak.is_empty():
		var damage = weak.pop_front()
		if damage_type == damage:
			amount *= 2
			resistances_message += "FOR %d HITPOINTS!!!!" % amount
	while !resistance.is_empty():
		var damage = resistance.pop_front()
		if damage_type == damage:
			amount /= 2
			resistances_message += ",for a pityful %d hit points." % amount
	
	while !imm.is_empty():
		var damage = imm.pop_front()
		if damage_type == damage:
			amount = 0
			resistances_message += " but they weren't fazed." 
	if resistances_message== "":
		resistances_message = " for a  %d hit points." % amount
	if amount<=defense:
		resistances_message = " but it didn't inflict damage"
		amount = 0
	damage_message+= resistances_message
	MessageLog.send_message(damage_message,GameColors.ENEMY_ATTACK)
	hp -= amount
	turns_not_in_combat = 0
	
func gain_random_stat(amount:int)-> void:
	randomize()
	var stats = {
	"power":power,
	"defense":defense,
	"quickness":quickness,
	"hp":max_hp}
	var ram = randi_range(0,3)
	var ran:Array
	ran = stats.values()
	var chosen_stat = ran.pop_at(ram)
	chosen_stat +=amount
	var names = stats.keys()
	var stat_name :String= names.pop_at(ram)
	MessageLog.send_message( "%s gains more " % entity.get_entity_name()+stat_name+" !" ,GameColors.WELCOME_TEXT)
func gain_xp(award:int):
	xp+=award
	MessageLog.send_message("%s gains %x xp"%[entity.get_entity_name(),award],GameColors.HEALTH_RECOVERED)
	if xp>= lv*2:
		level_up()
func die() -> void:
	var death_message: String
	var death_message_color: Color
	var death_audio:AudioStreamPlayer
	entity.texture = death_texture
	entity.modulate = death_color
	if death_sound!=null and entity.visible == true:
		death_audio = AudioStreamPlayer.new()
		add_child(death_audio)
		death_audio.set_stream(death_sound)
		death_audio.play()
	if get_map_data().player == entity:
		death_message = "You died!"
		death_message_color = GameColors.PLAYER_DIE
		SignalBus.player_died.emit()
	else:
		death_message = "%s is dead!" % entity.get_entity_name()
		death_message_color = GameColors.ENEMY_DIE
	if entity.ai_component != null:
		entity._handle_consumable(corpse_food)
		if !items_to_drop.is_empty():
			_handle_death_drops(items_to_drop)
		if credit_exp!=null:
			if credit_exp.ai_component!=null:
				credit_exp.ai_component.attacking_actor = null
			credit_exp.fighter_component.gain_xp((xp+1)*lv)
			credit_exp = null
		MessageLog.send_message(death_message, death_message_color)
	
	if entity.ai_component != null:
		entity.ai_component.queue_free()
		entity.ai_component = null
		entity.entity_name = "Remains of %s" % entity.entity_name
		entity.blocks_movement = false
		entity.type = Entity.EntityType.CORPSE
	get_map_data().unregister_blocking_entity(entity)

func reanimate()->void:
	entity.set_entity_type(entity._definition)
	pass
	

func passively_heal()->void:
	var new_heal :float
	new_heal = (20+2*(toughness_mod+wisdom_mod))*0.01 
	healed_amount += new_heal 
	
	if healed_amount>=1:
		hp+= roundi(healed_amount)
		healed_amount -=1

func _handle_death_drops(consumable_definition: Array[EntityDefinition]) -> void:
	var consumable_component
	var consume = consumable_definition.duplicate()
	while !consume.is_empty():
		
		var definition = consume.pop_front()
		consumable_component = Entity.new(entity.map_data, entity.grid_position, definition)
		entity.map_data.entities.append(consumable_component)
		entity.get_parent().add_child(consumable_component)
		
func get_weapon(entity:Entity,target_weapon:EquipmentItemComponent.WEAPON_TYPES)->Array[Entity]:
	var list = body_plan.get_children().duplicate()
	var return_list:Array[Entity]
	while !list.is_empty():
		var limb:Limb_Component= list.pop_front()
		var weapon:Entity = limb.equiped_item
		if weapon !=null:
			if weapon.equipment_item_component.weapon_type == target_weapon:
				return_list+=[weapon]
	return return_list
	
func get_body_part(entity:Entity,target_part:Body_Plan_Definition.TYPE_OF_PARTS)-> Array[Limb_Component]:
	var list = body_plan.get_children().duplicate()
	var return_list:Array[Limb_Component]
	while !list.is_empty():
		var limb:Limb_Component = list.pop_front()
		if limb.limb_type == target_part:
			return_list+=[limb]
	return return_list
