class_name PredatorAi
extends BaseAIComponent


var path: Array = []
var previous_direction:Vector2i
var previous_attacker_location:Vector2i
var attacking_actor
var radius:int = 8
var aggro_on_cooldown:bool = false
var aggro_cooldown:int = 0
var turns_wasted:int
var target_food:Entity
var user:Entity
var aggression:int
var map_data: MapData 
func perform() -> void:
	user = get_parent()
	aggression = user.fighter_component.aggression
	var preys =[]
	map_data = get_map_data()
	turns_wasted +=1
	var no_prey_in_sight = false
	if aggro_on_cooldown == true:
		aggro_cooldown+=1
	if aggro_cooldown>=5:
		aggro_cooldown = 0
		aggro_on_cooldown = false
	if turns_wasted>2:
		attacking_actor = null
		no_prey_in_sight = true
	if attacking_actor == null:
		for actor in map_data.get_actors():
			var agr = aggro(user.fighter_component.aggression)
			if map_data.get_tile(actor.grid_position).is_in_view and actor._definition!=user._definition and aggro_on_cooldown == false:
				if agr == false:
					attacking_actor = actor
					break
				else:
					aggro_on_cooldown = true
			if map_data.get_tile(actor.grid_position).is_in_view and actor.ai_component is PredatorAi and actor.ai_component.attacking_actor !=null and actor._definition == user._definition:
				attacking_actor = actor.ai_component.attacking_actor
				break
			if map_data.get_tile(actor.grid_position).is_in_view and actor.ai_component is PreyAi:
				preys.append(actor)
				if no_prey_in_sight == true:
					no_prey_in_sight = true
	if attacking_actor == null and !preys.is_empty()and no_prey_in_sight == false:
		for actor in preys:
			attacking_actor = actor
			var target: Entity = attacking_actor
			var target_grid_position: Vector2i = target.grid_position
			var offset: Vector2i = target_grid_position - entity.grid_position
			var distance: int = max(abs(offset.x), abs(offset.y))
			
			if distance <= 1:
				return MeleeAction.new(entity, offset.x, offset.y).perform()
			path = get_point_path_to(target_grid_position)
			path.pop_front()
			if not path.is_empty():
				var destination := Vector2i(path.pop_front())
				turns_wasted = 0
				var move_offset: Vector2i = destination - entity.grid_position
				return  BumpAction.new(entity, move_offset.x, move_offset.y).perform()
			attacking_actor = null
	if attacking_actor != null and attacking_actor.modulate != Color(255,255,255,20):
		if attacking_actor != null and attacking_actor.visible == true:
			var target: Entity = attacking_actor
			var target_grid_position: Vector2i = target.grid_position
			var offset: Vector2i = target_grid_position - entity.grid_position
			var distance: int = max(abs(offset.x), abs(offset.y))
			if get_map_data().get_tile(entity.grid_position).is_in_view:
				if distance <= 1:
					if user.fighter_component.skill_tracker.get_child_count()!=0:
						var skll = user.fighter_component.skill_tracker.get_children()
						var kick:Skills = skll.pick_random()
						
						if kick.tick_cooldown== kick.cooldown:
							
							return SkillAction.new(entity,kick,entity.map_data,offset).perform()
					return MeleeAction.new(entity, offset.x, offset.y).perform()
				path = get_point_path_to(target_grid_position)
				path.pop_front()
				if not path.is_empty():
					var destination := Vector2i(path.pop_front())
					var move_offset: Vector2i = destination - entity.grid_position
					turns_wasted = 0
					previous_attacker_location = attacking_actor.grid_position
					return  BumpAction.new(entity, move_offset.x, move_offset.y).perform()
		elif attacking_actor != null:
			print("fsfdsf","is_invisible")
			return MeleeAction.new(entity,random_dir().x,random_dir().y)
		walk_rando()
	elif attacking_actor != null:
		print("fsfdsf","is weirdcolor")
		return MeleeAction.new(entity,random_dir().x,random_dir().y)
	walk_rando()
	
func random_dir()-> Vector2i:
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
	var agr = user.dicebag.roll_dice(1,100,roundi((user.fighter_component.hunger)))
	if agr>=challenge:
		return true
	else: 
		return false
func walk_rando():
	if target_food == null and user.fighter_component.hunger< user.fighter_component.max_hunger-30:
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
		if coinflip <= 1:
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
				if map_data.get_tile(user.grid_position+chosen_direction).is_walkable():
					previous_direction = chosen_direction
					return MovementAction.new(entity,chosen_direction.x,chosen_direction.y).perform()
		else:
			var tile = get_map_data().get_tile(entity.grid_position+previous_direction)
			if tile ==null:
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
	
