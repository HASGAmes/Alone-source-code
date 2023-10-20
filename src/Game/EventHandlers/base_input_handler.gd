class_name BaseInputHandler
extends Node


func enter() -> void:
	pass


func exit() -> void:
	pass


func get_action(player: Entity) -> Action:
	if Input.is_action_just_pressed("COMMAND_LINE"):
		get_parent().transition_to(InputHandler.InputHandlers.MAIN_GAME)
	return null
