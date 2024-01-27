class_name DamageDealtConditions
extends BaseCondition
var conditiontype:int
var current_effect
var effect_target:Entity
func _init(definition:DamageDealtConditionsDefinition):
	conditiontype = definition.condition_parameters
	load_effect(definition.condition_effect)
func connect_condition(entity:Entity):
	var parent = get_parent()
	print("connecting")
	print(conditiontype)
	effect_target = entity
	if parent.currently_equipped == true:
		if conditiontype== 0:
			SignalBus.attacked.connect(hit)
			print("connected")
		if conditiontype== 1:
			SignalBus.critted.connect(critted)
			print("connected")
		if conditiontype== 2:
			SignalBus.missed.connect(miss)
			print("connected")
	if parent.currently_equipped == false:
		if conditiontype== 0:
			SignalBus.attacked.disconnect(hit)
			print("disconnected")
		if conditiontype== 1:
			SignalBus.critted.disconnect(critted)
			print("disconnected")
		if conditiontype== 2:
			SignalBus.missed.disconnect(miss)
			print("disconnected")
func load_effect(effect:BaseEffectDefinition):
	var baseeffect:BaseEffect
	if effect!=null:
		current_effect = effect.effect_id.new(effect)
	add_child(current_effect)
func hit(entity:Entity):
	print("works?",entity.get_entity_name(),effect_target.get_entity_name())
	if entity == effect_target:
		print("works!!")
		current_effect.effect_trigger.emit(effect_target)
	pass
func miss(entity:Entity):
	if entity == effect_target:
		current_effect.effect_trigger.emit(effect_target)
	pass
func critted(entity:Entity):
	if entity == effect_target:
		current_effect.effect_trigger.emit(effect_target)
	pass
