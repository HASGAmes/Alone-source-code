class_name PetAction
extends ActionWithDirection

func perform()->bool:
	var get_target = get_blocking_entity_at_destination()
	if get_target!=null:
		MessageLog.send_message("%s pets the %s"%[entity.get_entity_name(),get_target.get_entity_name()],GameColors.HEALTH_RECOVERED,entity)
		return true
	
	MessageLog.send_message("%s trys to pet the air...%s is very sad :("%[entity.get_entity_name(),entity.get_entity_name()],GameColors.HEALTH_RECOVERED,entity)
	return false
