class_name Limb_Definition
extends  Resource
@export_category("Mechanics")
@export var is_important :bool 
@export var name: String = "unnamed limb"
@export var limb_type:Body_Plan_Definition.TYPE_OF_PARTS
@export var can_be_dismembered:bool = true
@export var attached_parts: Array[Limb_Definition]
@export var damage_type:Array[DamageTypes.DAMAGE_TYPES]
@export var damage_dice:Array[int] = [2,1]
@export var is_natural_weapon:bool = false
@export var starting_equipment:EntityDefinition = null
