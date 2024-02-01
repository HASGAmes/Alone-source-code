class_name DamageTypeCondition
extends BaseCondition
var conditiontype:int
var current_effect
var effect_target:Entity
func _init(definition:DamageTypeConditionDefinition):
	conditiontype = definition.condition_parameters
	load_effect(definition.condition_effect)
func connect_condition(entity:Entity):
	var parent = get_parent()
	print("connecting")
	print(conditiontype)
	effect_target = entity
	if parent.currently_equipped == true:
		if conditiontype== 0:
			entity.fighter_component.damagestrong.connect(resistance)
			print("connected")
		if conditiontype== 1:
			entity.fighter_component.damageweak.connect(weak)
			print("connected")
		if conditiontype== 2:
			entity.fighter_component.damageimmune.connect(immune)
			print("connected")
	if parent.currently_equipped == false:
		if conditiontype== 0:
			entity.fighter_component.damagestrong.disconnect(resistance)
			print("disconnected")
		if conditiontype== 1:
			entity.fighter_component.damageweak.disconnect(weak)
			print("disconnected")
		if conditiontype== 2:
			entity.fighter_component.damageimmune.disconnect(immune)
			print("disconnected")
func load_effect(effect:BaseEffectDefinition):
	var baseeffect:BaseEffect
	if effect!=null:
		current_effect = effect.effect_id.new(effect)
	add_child(current_effect)
func resistance(damagetype:DamageTypes.DAMAGE_TYPES,entity:Entity):
	print("works?",entity.get_entity_name(),effect_target.get_entity_name())
	if entity == effect_target:
		print("works!!")
		current_effect.effect_trigger.emit(effect_target)
	pass
func weak(damagetype:DamageTypes.DAMAGE_TYPES,entity:Entity):
	if entity == effect_target:
		current_effect.effect_trigger.emit(effect_target)
	pass
func immune(damagetype:DamageTypes.DAMAGE_TYPES,entity:Entity):
	if entity == effect_target:
		current_effect.effect_trigger.emit(effect_target)
	pass
