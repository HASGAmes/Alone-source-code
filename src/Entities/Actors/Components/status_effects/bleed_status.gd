class_name  Bleed_Status
extends StatusBase
var damage:int
var turns:int
var statusname:String
var forever:bool
var stack:bool
func _init(definition: Bleed_Definition):
	damage = definition.damage
	turns = definition.turns
	statusname = definition.status_name
	stack = definition.can_stack
	forever = definition.is_indefinite
	
func activate_effect(entity:Entity) -> void:
	var damage_taken = entity.dicebag.roll_dice(1,damage)
	var damage_message = "%s bleeds for %d damage"% [entity.entity_name ,damage_taken]
	entity.fighter_component.take_damage(damage_taken,DamageTypes.DAMAGE_TYPES.PIERCING,damage_message)
	if forever == false:
		turns = turns -1
	if turns <=0:
		MessageLog.send_message("%s stops bleeding"%entity.entity_name,GameColors.STATUS_END)
		queue_free()
	pass
