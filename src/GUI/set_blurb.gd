extends PanelContainer
func set_blurb(entity:Entity)->void:
	$contain/contain/entityblurb.set_text(entity.blurb)
	$contain/entityname.set_text(entity.get_entity_name())
	$contain/entitypic.texture = entity.texture
	$contain/entitypic.modulate = entity.modulate
	
