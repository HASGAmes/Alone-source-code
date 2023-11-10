class_name RangedAction
extends ActionWithDirection
var bullets:int
var spread:float
var target:int
var look_target
var raycast = preload("res://assets/resources/bullet_raycast.tscn")
func _init(entity: Entity, target:Vector2i,bullets:int =1,spread:float =0.0):
	self.bullets = bullets
	self.spread = spread
	self.entity = entity
	look_target = target
	self.target = entity.map_data.get_tile(target).distance(entity.grid_position)
func perform() -> bool:
	var space_state = entity.get_world_2d().direct_space_state
	var user_ray:RayCast2D
	user_ray = raycast.instantiate()
	entity.add_child(user_ray)
	user_ray.position = Vector2i(8,8)
	
	user_ray.look_at(look_target*16)
	
	roundf(user_ray.rotation)
	
	user_ray.skew = randf_range(-spread,spread)
	user_ray.target_position.y = target*16
	
	print(user_ray.get_collider(),user_ray.target_position,user_ray.rotation)
	#entity.remove_child(user_ray)
	#user_ray.queue_free()
	return true
