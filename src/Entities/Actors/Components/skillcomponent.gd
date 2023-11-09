class_name SkillComponent
extends Component
var skills: Array[Skills]
var fight: FighterComponent
var total_slots:int
var body:Array[Node]
func _init(slots: FighterComponent) -> void:
	skills = []
	update_slots(slots)
func update_slots(slots:FighterComponent):
	self.fight = slots
	body = fight.get_children().duplicate()
	while !body.is_empty():
		total_slots+=1
		body.pop_front()
	body = slots.get_children().duplicate()
