class_name Temporal_Status
extends StatusBase
var turns:int
var statusname:String
var forever:bool
var root_path = get_parent()
@onready var animation:AnimationPlayer 
@onready var smoke = ResourceLoader.load("res://assets/resources/animations/smokeflutter.res")
func _init(definition:Temporal_Definition) -> void:
	turns = definition.turns
	statusname = definition.status_name
	forever = definition.is_indefinite
	animation = AnimationPlayer.new()
	add_child(animation)
	
	pass
func activate_effect(entity:Entity) -> void:
	animation.root_node = get_path_to(entity)
	print(animation.get_animation("smokeflutter"))
	animation.play()
	if forever== false:
		turns = turns -1
		print("works")
	if turns<=0:
		entity.map_data.entities.erase(entity)
		entity.queue_free()
	
	pass
