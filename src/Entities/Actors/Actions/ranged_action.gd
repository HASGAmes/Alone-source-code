class_name RangedAction
extends ActionWithDirection
var bullets:int
var spread:float
var target:Vector2i
var raycast = preload("res://assets/resources/bullet_raycast.tscn")
func _init(entity: Entity, target:Vector2i,bullets:int =1,spread:float =0.0):
	self.bullets = bullets
	self.spread = spread
	self.entity = entity
	self.target = target

func perform() -> bool:
	var space_state = entity.get_world_2d().direct_space_state
	var user_ray:RayCast2D
	user_ray = raycast.instantiate()
	entity.add_child(user_ray)
	var lookray = user_ray.grid_position
	user_ray.target_position = target*16
	print(lookray,target,user_ray.target_position)
	user_ray.position = Vector2i(8,8)
	user_ray.rotation += randf_range(-spread,spread)
	user_ray.force_raycast_update()
	var collider = await user_ray.get_collider()
	print(collider)
	var struck 
	if collider!=null:
		struck = collider.get_parent()
	if struck is Tile:
		print(struck.tile_name)
	if struck is Entity:
		print(struck.entity_name)
	#user_ray.rotation = 0
	#entity.remove_child(user_ray)
	#user_ray.queue_free()
	return true
