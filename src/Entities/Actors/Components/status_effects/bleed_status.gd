class_name  Bleed_Status
extends StatusBase
var damage:int
var turns:int
var statusname:String
var forever:bool
func _init(definition: Bleed_Definition):
	damage = definition.damage
	turns = definition.turns
	statusname = definition.status_name
	
	forever = definition.is_indefinite
	
func activate_effect(entity:Entity) -> void:
	var damage_taken = entity.dicebag.roll_dice(1,damage)
	entity.fighter_component.take_damage(damage_taken)
	if forever == false:
		turns = turns -1
	MessageLog.send_message("%s bleeds for %d damage"% [entity.entity_name ,damage_taken],GameColors.ENEMY_ATTACK)
	if turns <=0:
		queue_free()
	pass
