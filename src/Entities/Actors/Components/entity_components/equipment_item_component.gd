class_name  EquipmentItemComponent
extends Component

enum EQUIPMENT_TYPES{WEAPON,ARMOR,UTILITY}
enum WEAPON_TYPES{NOT_WEAPON,LONG_BLADE,AXE,HANDGUN,LONGGUN,BOW,SHORT_BLADE,CUDGEL,UNIQUE}
var equipment_type:EQUIPMENT_TYPES
var equipment_slot:Body_Plan_Definition.TYPE_OF_PARTS
var current_damagetypes:DamageTypes.DAMAGE_TYPES
var weapon_type:WEAPON_TYPES
var spread:float
var bullets:int
var condition:BaseCondition
var damage_dice:Array[int]
var currently_equipped:bool
func _init(definition:EquipmentDefinition):
	
	equipment_slot= definition.equipment_slot
	equipment_type = definition.equipment_type
	weapon_type = definition.weapon_type
	self.current_damagetypes = definition.damage_types
	self.bullets = definition.bullets
	self.spread  = definition.spread
	self.damage_dice = definition.damage_dice
	load_condition(definition.conditioneffects)
func load_condition(conditionarray:Array[BaseConditionDefinition]):
	var conditionthing = conditionarray.duplicate()
	while !conditionthing.is_empty():
		var currentcondition = conditionthing.pop_front()
		print(condition)
		condition = currentcondition.condition_id.new(currentcondition)
		add_child(condition)
	pass
