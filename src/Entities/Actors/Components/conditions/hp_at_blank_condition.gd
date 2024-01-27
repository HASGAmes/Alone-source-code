class_name HpatblankCondition
extends BaseCondition
var conditiontype:int
var hp_parameter:int
var currenthp:int
var current_effect
var effect_target:Entity
func _init(definition:HPatBlankDefinition):
	conditiontype = definition.condition_parameters
	hp_parameter = definition.hp_parameter
	load_effect(definition.condition_effect)
func connect_condition(entity:Entity):
	var parent = get_parent()
	print("connecting")
	print(conditiontype)
	effect_target = entity
	if parent.currently_equipped == true:
		if conditiontype== 0:
			print("connected")
			entity.fighter_component.hp_lowered.connect(less_than)
		if conditiontype== 1:
			entity.fighter_component.hp_lowered.connect(greater_than)
		if conditiontype== 2:
			entity.fighter_component.hp_lowered.connect(equal)
		if conditiontype== 3:
			entity.fighter_component.hp_lowered.connect(changed)
	if parent.currently_equipped == false:
		if conditiontype== 0:
			print("disconnected")
			entity.fighter_component.hp_lowered.disconnect(less_than)
		if conditiontype== 1:
			entity.fighter_component.hp_lowered.disconnect(greater_than)
		if conditiontype== 2:
			entity.fighter_component.hp_lowered.disconnect(equal)
		if conditiontype== 3:
			entity.fighter_component.hp_lowered.disconnect(changed)
func load_effect(effect:BaseEffectDefinition):
	var baseeffect:BaseEffect
	if effect!=null:
		current_effect = effect.effect_id.new(effect)
	add_child(current_effect)
func less_than(hp:int,maxhp:int):
	if hp<hp_parameter:
		#print("hmmmmmmmmmmm")
		current_effect.effect_trigger.emit(effect_target)
func greater_than(hp:int,maxhp:int):
	if hp>hp_parameter:
		current_effect.effect_trigger.emit(effect_target)
func equal(hp:int,maxhp:int):
	if hp==hp_parameter:
		current_effect.effect_trigger.emit(effect_target)
func changed(hp:int,maxhp:int):
	current_effect.effect_trigger.emit(effect_target)
