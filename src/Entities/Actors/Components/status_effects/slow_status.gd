class_name SlowStatus
extends StatusBase
var slow:int
var turns:int
var statusname:String
var forever:bool
var effect_triggered:bool
var org_quickness:int
var stack
func _init(definition: Slow_Definition):
	slow = definition.slow_amount
	turns = definition.turns
	statusname = definition.status_name
	print(definition.is_indefinite)
	stack = definition.can_stack
	forever = definition.is_indefinite
func activate_effect(entity:Entity) -> void:
	if effect_triggered == false:
		org_quickness = entity.fighter_component.quickness
		entity.fighter_component.quickness -= slow
		if entity.fighter_component.quickness<=0:
			entity.fighter_component.quickness = 1
			org_quickness-=1
	if forever== false:
		turns = turns -1
	if turns <=0:
		entity.fighter_component.quickness = org_quickness
		queue_free()
		
	pass
