class_name EntityDefinition
extends Resource

@export_category("Visuals")
@export var name: String = "Unnamed Entity"
@export var texture: AtlasTexture
@export_color_no_alpha var color: Color = Color.WHITE

@export_category("Mechanics")
@export var is_blocking_movment: bool = true
@export var type: Entity.EntityType
@export var starting_movement:Entity.MOVEMENT_TYPE = Entity.MOVEMENT_TYPE.WALK

@export_category("Components")
@export var fighter_definition: FighterComponentDefinition
@export var ai_type: Entity.AIType
@export var consumable_definition: ConsumableComponentDefinition
@export var inventory_capacity: int = 0
@export var starting_status:Array[StatusEffectDefinition]
@export var equipment_item_component:EquipmentDefinition
