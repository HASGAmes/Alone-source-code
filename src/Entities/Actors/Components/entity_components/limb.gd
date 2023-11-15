class_name Limb_Component
extends Component
var is_important :bool 
var name_limb
var limb_type
var can_be_dismembered:bool
var damage_dice:int
var natural_weapon:bool
var damage_sides:int
var connected:Array[Limb_Component]
var equiped_item:Entity
var equiped_item_definition:EntityDefinition
var attached_parts: Array[Limb_Definition]
var definition_limb:Limb_Definition
func _init(definition :Limb_Definition):
	definition_limb = definition.duplicate()
	natural_weapon = definition.is_natural_weapon
	damage_dice = definition.damage_dice
	damage_sides = definition.damage_dice_sides
	name_limb =definition_limb.name
	is_important = definition_limb.is_important
	can_be_dismembered = definition_limb.can_be_dismembered
	limb_type = definition_limb.limb_type
	attached_parts = definition_limb.attached_parts
func _can_be_dismembered() -> bool:
	return can_be_dismembered
func important_limb() -> bool:
	return is_important
