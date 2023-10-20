extends TextureRect

func initialize(player: Node2D) -> void:
	await ready
	
	texture = player.texture
