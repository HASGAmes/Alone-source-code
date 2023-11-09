extends TextureRect

func _ready() -> void:
	if SignalBus.player !=null:
		change_icon(SignalBus.player)
	SignalBus.player_changed.connect(change_icon)
	pass
func change_icon(player:Entity) -> void:
	texture = player.texture
	modulate = player.modulate
	
	
