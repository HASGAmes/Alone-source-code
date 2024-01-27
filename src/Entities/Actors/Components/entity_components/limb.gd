class_name Limb_Component
extends Component
var is_important :bool 
var name_limb
var limb_type
var can_be_dismembered:bool
var damage_dice:Array[int]
var natural_weapon:bool
var connected:Array[Limb_Component]
var equiped_item:Entity
var current_damagetypes:DamageTypes.DAMAGE_TYPES
var equiped_item_definition:EntityDefinition
var attached_parts: Array[Limb_Definition]
var definition_limb:Limb_Definition
func _init(definition :Limb_Definition):
	definition_limb = definition.duplicate()
	natural_weapon = definition.is_natural_weapon
	damage_dice = definition.damage_dice
	name_limb =definition_limb.name
	is_important = definition_limb.is_important
	current_damagetypes = definition.damage_type
	can_be_dismembered = definition_limb.can_be_dismembered
	limb_type = definition_limb.limb_type
	attached_parts = definition_limb.attached_parts
func _can_be_dismembered() -> bool:
	return can_be_dismembered
func important_limb() -> bool:
	return is_important
