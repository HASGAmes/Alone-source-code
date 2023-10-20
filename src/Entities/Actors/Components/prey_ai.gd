class_name PreyAi
extends BaseAIComponent


var path: Array = []
var previous_direction:Vector2i
var attacking_actor:Entity
var previous_attacker_location:Vector2i
var aggro_on_cooldown:bool = false
var aggro_cooldown:int = 0
var user:Entity
var aggression:int
var turns_wasted:int
func perform() -> void:
	
	if aggro_on_cooldown == true:
		aggro_cooldown+=1
	if aggro_cooldown>=5:
		aggro_cooldown = 0
		aggro_on_cooldown = false
	user = get_parent()
	aggression = user.fighter_component.aggression
	var map_data: MapData = get_map_data()
	if attacking_actor == null:
		for actor in map_data.get_actors():
			var agr = aggro(user.fighter_component.aggression)
			if map_data.get_tile(actor.grid_position).is_in_view and actor._definition!=user._definition and aggro_on_cooldown == false:
				if agr == false:
					attacking_actor = actor
					break
				else:
					aggro_on_cooldown = true
			if map_data.get_tile(actor.grid_position).is_in_view and actor.ai_component is PreyAi and actor.ai_component.attacking_actor !=null:
				attacking_actor = actor.ai_component.attacking_actor
	if attacking_actor != null:
		var target: Entity = attacking_actor
		var target_grid_position: Vector2i = target.grid_position
		var offset: Vector2i = target_grid_position - entity.grid_position
		var distance: int = max(abs(offset.x), abs(offset.y))
		if get_map_data().get_tile(entity.grid_position).is_in_view:
			if distance <= 1:
				return MeleeAction.new(entity, offset.x, offset.y).perform()
			path = get_point_path_to(target_grid_position)
			path.pop_front()
			if not path.is_empty():
				var destination := Vector2i(path.pop_front())
				var move_offset: Vector2i = destination - entity.grid_position
				turns_wasted = 0
				previous_attacker_location = attacking_actor.grid_position
				return  BumpAction.new(entity, move_offset.x, move_offset.y).perform()
		elif get_map_data().get_tile(previous_attacker_location).is_in_view:
			target_grid_position = previous_attacker_location
			offset = target_grid_position - entity.grid_position
			distance = max(abs(offset.x), abs(offset.y))
			path = get_point_path_to(target_grid_position)
			path.pop_front()
			randomize()
			var forgiven = entity.dicebag.roll_dice(1,20,0)
			if forgiven>aggression and attacking_actor !=null:
				#MessageLog.send_message("lost",GameColors.INVALID)
				attacking_actor =null
			if not path.is_empty():
				var destination := Vector2i(path.pop_front())
				var move_offset: Vector2i = destination - entity.grid_position
				turns_wasted = 0
				return  BumpAction.new(entity, move_offset.x, move_offset.y).perform()
		walk_rando()
	walk_rando()
func wander()-> Vector2i:
	var direction: Vector2i = [
			Vector2i(-1, -1),
			Vector2i( 0, -1),
			Vector2i( 1, -1),
			Vector2i(-1,  0),
			Vector2i( 1,  0),
			Vector2i(-1,  1),
			Vector2i( 0,  1),
			Vector2i( 1,  1),
		].pick_random()
	return direction
func aggro(challenge:int) -> bool:
	var agr = user.dicebag.roll_dice(1,20,roundi((user.fighter_component.hunger/10)))
	if agr>=challenge:
		return true
	else: 
		return false
func walk_rando():
	if previous_direction==null:
		var go = wander()
		previous_direction = go
		var forgiven = entity.dicebag.roll_dice(1,20,0)
		if forgiven>=aggression:
			attacking_actor =null
		turns_wasted = 0
		return BumpAction.new(entity,go.x,go.y).perform()
	else:
		var coinflip = entity.dicebag.roll_dice(1,6)
		if coinflip <3:
			var go = wander()
			previous_direction = go
			randomize()
			var forgiven = entity.dicebag.roll_dice(1,20,0)
			if forgiven>aggression and attacking_actor !=null:
				#MessageLog.send_message("lost",GameColors.INVALID)
				attacking_actor =null
			turns_wasted = 0
			return MovementAction.new(entity,go.x,go.y).perform()
		else:
			var tile = get_map_data().get_tile(entity.grid_position+previous_direction)
			if tile.is_walkable():
				randomize()
				var forgiven = entity.dicebag.roll_dice(1,20,0)
				if forgiven>aggression and attacking_actor !=null:
					#MessageLog.send_message("lost",GameColors.INVALID)
					attacking_actor =null
				turns_wasted = 0
				return MovementAction.new(entity,previous_direction.x,previous_direction.y).perform()
			else:
				randomize()
				var forgiven = entity.dicebag.roll_dice(1,20,0)
				if forgiven>aggression and attacking_actor !=null:
					#MessageLog.send_message("lost",GameColors.INVALID)
					attacking_actor =null
				var go = wander()
				previous_direction = go
				turns_wasted = 0
				return MovementAction.new(entity,go.x,go.y).perform()
	
