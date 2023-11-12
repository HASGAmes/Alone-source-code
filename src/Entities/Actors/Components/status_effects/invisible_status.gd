class_name InvisibleStatus
extends StatusBase
var turns:int
var statusname:String
var forever:bool
var previoshp
var effect_applied:bool = false
var stack:bool
func _init(status:InvisibleDefinition) -> void:
	forever = status.is_indefinite
	stack = status.can_stack
	turns =status.turns
	pass
func activate_effect(entity:Entity) -> void:
	if entity.map_data.get_tile(entity.grid_position).is_in_view:
		if entity.visible == true:
			effect_applied = false
	if effect_applied == false and entity.visible == true:
		effect_applied = true
		if entity == entity.get_parent().get_parent().get_parent().player:
			entity.modulate = Color(255,255,255,20)
		else:
			entity.visible = false
	if previoshp == null:
		previoshp = entity.fighter_component.hp
	
	if forever == false:
		turns -= 1
	randomize()
	var chance = entity.dicebag.roll_dice(1,100,0)
	if entity.fighter_component.hp <previoshp:
		MessageLog.send_message("%s's cloak got damaged in the fight"%entity.get_entity_name(),GameColors.STATUS_END,entity)
		entity.visible = true
		entity.modulate= entity._definition.color
		queue_free()
	elif turns <= 0:
		MessageLog.send_message("%s's cloak ran out of juice!!"%entity.get_entity_name(),GameColors.STATUS_END,entity)
		if entity.map_data.get_tile(entity.grid_position).is_in_view:
			entity.visible = true
		entity.modulate= entity._definition.color
		
		queue_free()
	pass
