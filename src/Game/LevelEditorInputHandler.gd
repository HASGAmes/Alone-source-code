extends BaseInputHandler
@onready var player_cam:Camera2D = %"Camera2D"
@onready var editor_cam:Camera2D = %"editorcam"
func enter() -> void:
	editor_cam.global_position = player_cam.global_position
	editor_cam.make_current()
	pass


func exit() -> void:
	player_cam.make_current.call_deferred()
	pass


func get_action(player: Entity) -> Action:
	return null
