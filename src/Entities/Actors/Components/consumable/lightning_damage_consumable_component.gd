class_name LightningDamageConsumableComponent
extends ConsumableComponent

var damage: int = 0
var maximum_range: int = 0
var defintion

func _init(definition: LightningDamageConsumableComponentDefinition) -> void:
	damage = definition.damage
	maximum_range = definition.maximum_range
	defintion = definition


func activate(action: ItemAction) -> bool:
	var consumer: Entity = action.entity
	var target: Entity = null
	var closest_distance: float = maximum_range + 1
	var map_data: MapData = get_map_data()
	
	for actor in map_data.get_actors():
		if actor != consumer and map_data.get_tile(actor.grid_position).is_in_view:
			var distance: float = consumer.distance(actor.grid_position)
			if distance < closest_distance:
				target = actor
				closest_distance = distance
	
	if target:
		play_sound(defintion)
		var message = "The taser zaps %s " % target.get_entity_name()
		target.fighter_component.take_damage(damage,DamageTypes.DAMAGE_TYPES.ELECTRIC,message)
		consume(consumer)
		return true
	
	MessageLog.send_message("No enemy is close enough to strike.", GameColors.IMPOSSIBLE)
	return false
