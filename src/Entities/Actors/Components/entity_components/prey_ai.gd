class_name PreyAi
extends BaseAIComponent


var path: Array = []
var previous_direction:Vector2i
var attacking_actor:Entity
var previous_attacker_location:Vector2i
var aggro_on_cooldown:bool = false
var aggro_cooldown:int = 0
var user:Entity
var target_food:Entity
var aggression:int
var turns_wasted:int
var map_data: MapData 
var list_of_friendlys:Array[Entity]
func perform() -> void:
	
	if aggro_on_cooldown == true:
		aggro_cooldown+=1
	if aggro_cooldown>=5:
		aggro_cooldown = 0
		aggro_on_cooldown = false
	user = get_parent()
	aggression = user.fighter_component.aggression
	map_data = get_map_data()
	if attacking_actor!=null:
		if !attacking_actor.is_alive():
			attacking_actor = null
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
	if attacking_actor != null and attacking_actor.modulate != Color(255,255,255,20):
		if attacking_actor != null and attacking_actor.visible == true:
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
		elif attacking_actor != null:
			return MeleeAction.new(entity,wander().x,wander().y)
		walk_rando()
	elif attacking_actor != null:
		return MeleeAction.new(entity,wander().x,wander().y)
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

func possible_directions() ->Array[Vector2i]:
	var direction: Array[Vector2i] 
	direction = [
			Vector2i(-1, -1),
			Vector2i( 0, -1),
			Vector2i( 1, -1),
			Vector2i(-1,  0),
			Vector2i( 1,  0),
			Vector2i(-1,  1),
			Vector2i( 0,  1),
			Vector2i( 1,  1),
		]
	return direction.duplicate()


func aggro(challenge:int) -> bool:
	var agr = user.dicebag.roll_dice(1,200,roundi((user.fighter_component.hunger/10)))
	if agr>=challenge:
		return true
	else: 
		return false
func walk_rando():
	if target_food == null and user.fighter_component.hunger!= user.fighter_component.max_hunger:
		for item in map_data.get_items():
			if item.consumable_component == FoodConsumable and map_data.get_tile(item.grid_position).is_in_view:
				target_food = item
	if target_food != null:
		var target: Entity = target_food
		var target_grid_position: Vector2i = target.grid_position
		var offset: Vector2i = target_grid_position - entity.grid_position
		var distance: int = max(abs(offset.x), abs(offset.y))
		if get_map_data().get_tile(entity.grid_position).is_in_view:
			if distance <= 1:
				map_data.entities.erase(target_food)
				return ItemAction.new(user, target_food).perform()
			path = get_point_path_to(target_grid_position)
			path.pop_front()
			if not path.is_empty():
				var destination := Vector2i(path.pop_front())
				var move_offset: Vector2i = destination - entity.grid_position
				turns_wasted = 0
				return  MovementAction.new(entity, move_offset.x, move_offset.y).perform()
	if previous_direction==null:
		var go = possible_directions()
		var forgiven = entity.dicebag.roll_dice(1,20,0)
		if forgiven>=aggression:
			attacking_actor =null
		turns_wasted = 0
		var chosen_direction
		while !go.is_empty():
			randomize()
			var coinflip = entity.dicebag.roll_dice(1,3)
			if  coinflip == 1:
				chosen_direction = go.pick_random()
			elif coinflip == 2:
				chosen_direction = go.pick_random()
			elif  coinflip == 3:
				chosen_direction = go.pick_random()
			if map_data.get_tile(user.grid_position+chosen_direction).is_walkable():
				previous_direction = chosen_direction
				return MovementAction.new(entity,chosen_direction.x,chosen_direction.y).perform()
	else:
		randomize()
		var coinflip = entity.dicebag.roll_dice(1,6)
		if coinflip <= 2:
			var go = possible_directions()
			var forgiven = entity.dicebag.roll_dice(1,20,0)
			if forgiven>=aggression:
				attacking_actor =null
			turns_wasted = 0
			var chosen_direction
			while !go.is_empty():
				randomize()
				coinflip = entity.dicebag.roll_dice(1,3)
				if  coinflip == 1:
					chosen_direction = go.pick_random()
				elif coinflip == 2:
					chosen_direction = go.pick_random()
				elif  coinflip == 3:
					chosen_direction = go.pick_random()
				var tile = map_data.get_tile(user.grid_position+chosen_direction)
				if tile == null:
					return
				if tile.is_walkable():
					previous_direction = chosen_direction
					return MovementAction.new(entity,chosen_direction.x,chosen_direction.y).perform()
		else:
			var tile = get_map_data().get_tile(entity.grid_position+previous_direction)
			if tile == null:
				return
			if tile.is_walkable():
				randomize()
				var forgiven = entity.dicebag.roll_dice(1,20,0)
				if forgiven>aggression and attacking_actor !=null:
					#MessageLog.send_message("lost",GameColors.INVALID)
					attacking_actor =null
				turns_wasted = 0
				return MovementAction.new(entity,previous_direction.x,previous_direction.y).perform()
			else:
				var go = possible_directions()
				var forgiven = entity.dicebag.roll_dice(1,20,0)
				if forgiven>=aggression:
					attacking_actor =null
				turns_wasted = 0
				var chosen_direction
				while !go.is_empty():
					randomize()
					coinflip = entity.dicebag.roll_dice(1,3)
					if  coinflip == 1:
						chosen_direction = go.pop_at(go.size()-1)
					elif coinflip == 2:
						chosen_direction = go.pop_at(go.size()-1)
					elif  coinflip == 3:
						chosen_direction = go.pop_at(go.size()-1)
					if map_data.get_tile(user.grid_position+chosen_direction).is_walkable():
						previous_direction = chosen_direction
						return MovementAction.new(entity,chosen_direction.x,chosen_direction.y).perform()
	
