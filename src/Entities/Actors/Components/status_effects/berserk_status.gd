## This status lets actors rampage and get bonus damage for killing
class_name BerserkStatus
extends StatusBase
var bonus_damage:int
var turns:int
var statusname:String
var forever:bool
var stack:bool
var power:int = 0
var xp:int = 0
func _init(definition: BerserkStatusDefinition):
	self.bonus_damage = definition.bonus_damage
	self.turns = definition.turns
	self.statusname = definition.status_name
	self.stack = definition.can_stack
	self.forever = definition.is_indefinite
	
func activate_effect(entity:Entity) -> void:
	var screen :CanvasModulate=SignalBus.screeneffects
	if power == 0:
		power = entity.fighter_component.power
		xp = entity.fighter_component.xp
		entity.fighter_component.turns_not_in_combat = 0
		if entity.map_data.player == entity:
			screen.color = Color.TOMATO
	if power == entity.fighter_component.power:
		entity.fighter_component.power+=bonus_damage
	if entity.fighter_component.power !=power +bonus_damage:
		print(entity.fighter_component.power,power,bonus_damage)
		entity.fighter_component.power+=bonus_damage
	if entity.fighter_component.turns_not_in_combat>=turns:
		end_effect(entity)
	if xp != entity.fighter_component.xp:
		bonus_damage+=3
		xp = entity.fighter_component.xp
		MessageLog.send_message("The %s rampage grows!!"%entity.get_entity_name(),GameColors.PLAYER_DIE) 
	elif entity.fighter_component.turns_not_in_combat>turns:
		MessageLog.send_message("NEED BLOOD!!!",GameColors.PLAYER_DIE)
	elif entity.fighter_component.turns_not_in_combat == 0:
		MessageLog.send_message("BLOOD!!!",GameColors.PLAYER_DIE)
func end_effect(entity:Entity)-> void:
	var screen :CanvasModulate
	screen = entity.get_parent().get_parent().screeneffects
	MessageLog.send_message("%s has calmed down"%entity.get_entity_name(),GameColors.STATUS_END)
	screen.color = Color.WHITE
	entity.fighter_component.power = power
	power = 0
	queue_free()
