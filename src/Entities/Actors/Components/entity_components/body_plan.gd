class_name Body_Plan
extends FighterComponent

var list_of_limbs: Array[Limb_Definition]#a array of an entities limbs
var original_limbs: Array[Limb_Definition]#a array of an entities orignal limbs
var list_of_equipment_limbs: Array[Limb_Component]# a array of all the limbs with equipment
var amount_of_important_limbs# this is the total important limbs like the head but not limited to
var adding_limbs: Limb_Component# a var used to add limbs
var stored_limbs:Array[Limb_Component]# a array used to store limbs for a bit
var limb_is_alive:bool = false# if true limbs that are severed will come to life
var parent:Entity#var for the parent entity
#used to inflict bleed on lost limb
var bleed:StatusEffectDefinition = load("res://assets/definitions/status_effects/severed_limb_bleeding.tres")
# used as the body plan if the limb is alive
var limb:EntityDefinition = load("res://assets/definitions/body_plans/limb.tres")
func _init(definition: Body_Plan_Definition,parent:Entity) -> void:
	original_limbs = definition.body_parts
	limb_is_alive = definition.limbs_are_alive
	self.parent = parent
	if definition.body_parts!=null:
		set_upbody(definition)
#### this starts setting up the body plan for a entity
func set_upbody(definition:Body_Plan_Definition) ->void:
	list_of_limbs = definition.body_parts
	amount_of_important_limbs=definition.amount_of_important_limbs
	original_limbs = list_of_limbs
	while !list_of_limbs.is_empty():#this adds all of the limbs one by one
		# it also deletes list of limbs in the process and is why the orignal limbs is a thing
		var current_definition:Limb_Definition = definition.body_parts.front()
		adding_limbs = Limb_Component.new(current_definition)
		adding_limbs.definition_limb = current_definition
		print(current_definition.starting_equipment)
		if current_definition.starting_equipment !=null:# if true adds equipment to limb
			adding_limbs.equiped_item_definition = current_definition.starting_equipment
		list_of_limbs.erase(list_of_limbs.front())
		add_child(adding_limbs)
		list_of_equipment_limbs.append(adding_limbs)
		track_importantlimbs(adding_limbs)
		while !adding_limbs.attached_parts.is_empty():
			var attached:Limb_Component
			var current_part = adding_limbs.attached_parts.pop_front()
			attached = Limb_Component.new(current_part)
			adding_limbs.connected+=[attached]
			if current_part.starting_equipment !=null:
				attached.equiped_item_definition = current_part.starting_equipment
			adding_limbs.get_parent().add_child(attached)
	list_of_limbs = original_limbs
func track_importantlimbs(important_limbs:Limb_Component):# tracks all important limbs like the head
	if important_limbs.important_limb():
		amount_of_important_limbs+=1
		#print(amount_of_important_limbs)
func addlimb()->void:#this func actually adds the limb
	pass
func removelimb()->void:#this func actually removes the limb
	pass
func dismember(can_decap: bool) -> void:# this func starts the process of removing limbs
	var dismemberable :Array=[Limb_Component]#list of dismemberable limbs
	dismemberable = get_children()
	var dismember_target = get_parent()#gets fighter component
	var chosen_limb = dismemberable.pick_random()
	if chosen_limb!=null:
		if can_decap ==true:
			while !chosen_limb._can_be_dismembered()and !dismemberable.is_empty():
				dismemberable.erase(dismemberable.front())
				if !dismemberable.is_empty():
					chosen_limb = dismemberable.pick_random()
		else:
			while !chosen_limb._can_be_dismembered()and !dismemberable.is_empty()and !chosen_limb.important_limb():
				dismemberable.erase(dismemberable.front())
				if !dismemberable.is_empty():
					chosen_limb = dismemberable.pick_random()
		var message ="The %s has lost their %s" % [dismember_target.get_parent().get_entity_name(), chosen_limb.name_limb]
		if chosen_limb.important_limb()and can_decap ==true:
			adding_limbs=chosen_limb
			stored_limbs.append(adding_limbs)
			amount_of_important_limbs -= 1
			var new_entity: Entity
			var map_data = get_parent().get_parent().map_data
			var pare = get_parent().get_parent()
			new_entity = Entity.new(map_data,pare.grid_position + random_dir(),limb)
			map_data.entities.append(new_entity)
			var arry:Array[StatusEffectDefinition]
			arry += [bleed]
			pare.add_status(arry)
			if limb_is_alive == false:
				limb.ai_type = Entity.AIType.NONE
				var spr = load("res://assets/resources/limb_sprite.tres")
				new_entity.texture = spr
				limb.fighter_definition = null
				new_entity.type = Entity.EntityType.CORPSE
				new_entity.fighter_component = null
				new_entity.ai_component = null
				new_entity.blocks_movement = false
			
			if chosen_limb == get_parent().current_primary_limb or chosen_limb.connected.pick_random() ==get_parent().current_primary_limb:
				var ary :Array =get_parent().total_attacking_limbs
				ary.erase(chosen_limb)
				get_parent().set_attacking_limbs(null,get_parent().total_attacking_limbs.pick_random())
			pare.get_parent().add_child(new_entity)
			while !chosen_limb.connected.is_empty():
				var li = chosen_limb.connected.pop_front()
				remove_child(li)
			new_entity.entity_name = pare.entity_name +"'s "+ chosen_limb.name_limb
			remove_child(chosen_limb)
			
			MessageLog.send_message(message, GameColors.CRIT,get_parent().get_parent())
		elif chosen_limb._can_be_dismembered() and !chosen_limb.important_limb():
			adding_limbs=chosen_limb
			stored_limbs.append(adding_limbs)
			var new_entity: Entity
			var map_data = get_parent().get_parent().map_data
			var pare:Entity= get_parent().get_parent()
			var arry:Array[StatusEffectDefinition]
			arry += [bleed]
			pare.add_status(arry)
			new_entity = Entity.new(map_data,pare.grid_position + random_dir(),limb)
			map_data.entities.append(new_entity)
			pare.get_parent().add_child(new_entity)
			if limb_is_alive == false:
				var spr = load("res://assets/resources/limb_sprite.tres")
				new_entity.texture = spr
				limb.ai_type = Entity.AIType.NONE
				limb.fighter_definition = null
				limb.type = Entity.EntityType.CORPSE
				new_entity.fighter_component = null
				new_entity.ai_component = null
				new_entity.blocks_movement = false
				new_entity.type = Entity.EntityType.CORPSE
			new_entity.entity_name = pare.entity_name +"'s "+ chosen_limb.name_limb
			while !chosen_limb.connected.is_empty():
				var li = chosen_limb.connected.pop_front()
				remove_child(li)
			remove_child(chosen_limb)
			dismember_target.get_parent().equipment_component.update_slots(self)
			MessageLog.send_message(message, GameColors.CRIT,get_parent().get_parent())
		#print(dismemberable)
		if amount_of_important_limbs==0 and chosen_limb.important_limb():
			dismember_target.hp = 0
		
	else:
		print("shame")
	
func regen_limb():
	if !stored_limbs.is_empty():
		var regrow = stored_limbs.pick_random()
		stored_limbs.erase(regrow)
		add_child(regrow)
		if !regrow.attached_parts.is_empty():
			var attached
			regrow.add_child(attached)
			#print(regrow.get_children())
		var messsage ="The %s has regrown their %s!!" % [get_parent().get_parent().get_entity_name(), regrow.name_limb]
		track_importantlimbs(regrow)
		MessageLog.send_message(messsage,GameColors.HEALTH_RECOVERED,get_parent().get_parent())
	
	
func random_dir()-> Vector2i:
	var direction: Vector2i = [
			Vector2i(-1, -1),
			Vector2i( 0, -1),
			Vector2i( 1, -1),
			Vector2i(-1,  0),
			Vector2i( 1,  0),
			Vector2i(-1,  1),
			Vector2i( 0,  1),
			Vector2i( 1,  1),
		].pick_random()
	return direction
