class_name HungryStatus
extends StatusBase

var turns:int
var statusname:String
var forever:bool
var definition:HungryDefinition
var stage:int = 1
var original_pow:int = 0
var original_quick:int = 0
var stack:bool
func _init(definition: HungryDefinition):
	self.definition = definition.duplicate()
	turns = definition.turns
	statusname = definition.status_name
	stack = definition.can_stack
	forever = definition.is_indefinite
	
func activate_effect(entity:Entity) -> void:
	turns-=1
	if stage ==1 and turns <=0:
		stage+=1
		turns = definition.turns
		original_pow = entity.fighter_component.power
		entity.fighter_component.power-2
		#queue_free()
	if stage ==2 and turns <=0:
		stage+=1
		turns = definition.turns
		original_quick = entity.fighter_component.quickness
		entity.fighter_component.quickness-20
		#queue_free()
	if entity.fighter_component.hunger>0:
		if original_pow !=0:
			entity.fighter_component.power = original_pow
		if original_quick !=0:
			entity.fighter_component.quickness
		queue_free()
	pass
