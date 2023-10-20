class_name EquipmentComponent
extends Component

var equiped_items: Array[Entity]
var slots: Body_Plan


func _init(slots: Body_Plan) -> void:
	equiped_items = []
	self.slots = slots


#func drop(item: Entity) -> void:
#	equiped_items.erase(item)
#	var map_data: MapData = get_map_data()
#	map_data.entities.append(item)
#	map_data.entity_placed.emit(item)
#	item.map_data = map_data
#	item.grid_position = entity.grid_position
#	MessageLog.send_message("You dropped the %s." % item.get_entity_name(), Color.WHITE)
