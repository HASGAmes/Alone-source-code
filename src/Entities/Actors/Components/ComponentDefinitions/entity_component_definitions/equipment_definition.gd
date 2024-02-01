class_name EquipmentDefinition
extends  ItemComponentDefinition
@export_category("Type of equipment")
@export var equipment_slot: Body_Plan_Definition.TYPE_OF_PARTS
@export var equipment_type:EquipmentItemComponent.EQUIPMENT_TYPES
@export var weapon_type:EquipmentItemComponent.WEAPON_TYPES
@export_category("Equipment bonuses")
## for all weapons
@export var damage_dice:Array[int]
@export var damage_types:Array[DamageTypes.DAMAGE_TYPES]= [DamageTypes.DAMAGE_TYPES.BLUDGEONING]
## for armor
@export var defense:int
## for guns
@export_range(1,100) var bullets:int = 1
@export_range(0.0,3.0) var spread:float = 0
@export_category("Equipment bonuses")
@export var conditioneffects:Array[BaseConditionDefinition]
