class_name EquipmentComponent
extends Component

var equiped_items: Array[Entity]
var slots: Body_Plan
var total_slots:int
var body:Array[Node]
func _init(slots: Body_Plan) -> void:
	equiped_items = []
	update_slots(slots)
func update_slots(slots:Body_Plan):
	self.slots = slots
	body = slots.get_children().duplicate()
	while !body.is_empty():
		total_slots+=1
		body.pop_front()
	body = slots.get_children().duplicate()
func drop(item: Entity) -> void:
	equiped_items.erase(item)
	var map_data: MapData = get_map_data()
	map_data.entities.append(item)
	map_data.entity_placed.emit(item)
	item.map_data = map_data
	item.grid_position = entity.grid_position
	MessageLog.send_message("You dropped the %s." % item.get_entity_name(), Color.WHITE)
