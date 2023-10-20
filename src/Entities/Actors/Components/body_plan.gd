class_name Body_Plan
extends Component
var list_of_limbs: Array[Limb_Definition]
var original_limbs: Array[Limb_Definition]
var list_of_equipment_limbs: Array[Limb_Component]
var amount_of_important_limbs
var adding_limbs: Limb_Component
var stored_limbs:Array[Limb_Component]
func _init(definition: Body_Plan_Definition) -> void:
	original_limbs = definition.body_parts
	if definition.body_parts!=null:
		set_up_body(definition)
func set_up_body(definition:Body_Plan_Definition):
	list_of_limbs = definition.body_parts
	amount_of_important_limbs=definition.amount_of_important_limbs
	original_limbs = list_of_limbs
	#print(list_of_limbs)
	while !list_of_limbs.is_empty():
		adding_limbs = Limb_Component.new(definition.body_parts.front())
		adding_limbs.definition_limb
		list_of_limbs.erase(list_of_limbs.front())
		
		add_child(adding_limbs)
		list_of_equipment_limbs.append(adding_limbs)
		track_importantlimbs(adding_limbs)
		if !adding_limbs.attached_parts.is_empty():
			var attached:Limb_Component
			attached = Limb_Component.new(definition.body_parts.front())
			adding_limbs.add_child(attached)
		#print(get_child_count())
	list_of_limbs = original_limbs
		#print(adding_limbs)
	#print(get_child_count())
func track_importantlimbs(important_limbs:Limb_Component):
	if important_limbs.important_limb():
		amount_of_important_limbs+=1
		#print(amount_of_important_limbs)
func dismember(can_decap: bool) -> void:
	var dismemberable :Array=[Limb_Component]
	dismemberable = get_children()
	var dismember_target = get_parent()
	#get_child()
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
		var messsage ="The %s has lost their %s" % [get_parent().get_parent().get_entity_name(), chosen_limb.name_limb]
		if chosen_limb.important_limb()and can_decap ==true:
			#print("should wor")
			adding_limbs=chosen_limb
			stored_limbs.append(adding_limbs)
			amount_of_important_limbs -= 1
			remove_child(chosen_limb)
			MessageLog.send_message(messsage, GameColors.CRIT)
		elif chosen_limb._can_be_dismembered() and !chosen_limb.important_limb():
			adding_limbs=chosen_limb
			stored_limbs.append(adding_limbs)
			remove_child(chosen_limb)
			MessageLog.send_message(messsage, GameColors.CRIT)
		#print(dismemberable)
		if amount_of_important_limbs==0:
			dismember_target.hp = 0
		print(stored_limbs)
		print(chosen_limb.attached_parts)
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
		MessageLog.send_message(messsage,GameColors.HEALTH_RECOVERED)
	
	

