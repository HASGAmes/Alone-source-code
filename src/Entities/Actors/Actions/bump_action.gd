class_name BumpAction
extends ActionWithDirection


func perform() -> bool:
	if get_target_actor():
		return MeleeAction.new(entity, offset.x, offset.y).perform()
	if get_target_tile():
		if get_target_tile().destructible == true and get_target_tile().openable==false:
			return MeleeAction.new(entity, offset.x, offset.y).perform()
		elif get_target_tile().openable==true and get_target_tile().opened == false:
			print("hm")
			get_target_tile().open_or_close()
			return true
		return MovementAction.new(entity, offset.x, offset.y).perform()
	return  MovementAction.new(entity, offset.x, offset.y).perform()
