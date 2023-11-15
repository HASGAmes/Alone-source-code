class_name RangedAction
extends ActionWithDirection
var bullets:int
var spread:float
var target:Vector2i
var damage_dice:Array[int]
var raycast = preload("res://assets/resources/bullet_raycast.tscn")
var line = preload("res://assets/resources/line_2d.tscn")
func _init(entity: Entity, target:Vector2i,damage_dice:Array[int],bullets:int =1,spread:float =0.0):
	self.bullets = bullets
	self.spread = spread
	self.entity = entity
	self.target = target
	self.damage_dice = damage_dice
	
func perform() -> bool:
	var space_state = entity.get_world_2d().direct_space_state
	var user_ray:RayCast2D
	var trace:Line2D
	while bullets>0:
		randomize()
		print("is blassting")
		var rolling_dice = damage_dice.duplicate()
		var damage = entity.dicebag.roll_dice(rolling_dice.pop_front(),rolling_dice.pop_front())
		user_ray = raycast.instantiate()
		trace = line.instantiate()
		entity.add_child(trace)
		entity.add_child(user_ray)
		var lookray = user_ray.grid_position
		trace.position = Vector2i(8,8)
		user_ray.target_position = target*320
		trace.points = [entity.grid_position,user_ray.target_position]
		print(lookray,target,user_ray.target_position)
		user_ray.position = Vector2i(8,8)
		user_ray.rotation += randf_range(-spread,spread)
		trace.rotation = user_ray.rotation
		user_ray.force_raycast_update()
		var collider = await user_ray.get_collider()
		print(collider)
		var struck 
		if collider!=null:
			struck = collider.get_parent()
		if struck is Tile:
			print(struck.tile_name)
			
		if struck is Entity:
			if struck.fighter_component!=null and struck.is_alive():
				var damage_message = "%s is caught in a blast of pellets"% struck.get_entity_name()
				struck.ai_component.attacking_actor = entity
				struck.fighter_component.take_damage(damage,DamageTypes.DAMAGE_TYPES.PIERCING,damage_message)
			print(struck.entity_name)
		bullets-=1
		user_ray.rotation = 0
		entity.remove_child(user_ray)
		user_ray.queue_free()
	return true
