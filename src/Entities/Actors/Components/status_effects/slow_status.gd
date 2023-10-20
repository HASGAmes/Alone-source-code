class_name SlowStatus
extends StatusBase
var slow:int
var turns:int
var statusname:String
var forever:bool
var effect_triggered:bool
var org_quickness:int
func _init(definition: Slow_Definition):
	slow = definition.slow_amount
	turns = definition.turns
	statusname = definition.status_name
	print(definition.is_indefinite)
	forever = definition.is_indefinite
func activate_effect(entity:Entity) -> void:
	if effect_triggered == false:
		org_quickness = entity.fighter_component.quickness
		entity.fighter_component.quickness -= slow
	if forever== false:
		turns = turns -1
	if turns <=0:
		entity.fighter_component.quickness = org_quickness
		queue_free()
		
	pass
