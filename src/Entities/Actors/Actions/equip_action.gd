class_name Equip_Action
extends Action

var Item:Entity
var limb:Limb_Component
func _init(entity: Entity,selected_limb:Limb_Component,selected_item:Entity) -> void:
	self.entity = entity
	limb = selected_limb
	Item = selected_item

func perform() -> bool:
	if limb.equiped_item!= null:
		entity.inventory_component.items.append(limb.equiped_item)
		limb.equiped_item = null
	limb.equiped_item = Item
	entity.inventory_component.items.erase(Item)
	MessageLog.send_message("The %s equips the %s to their %s"%[entity.get_entity_name(),Item.get_entity_name(),limb.name_limb],GameColors.HEALTH_RECOVERED)
	return true

