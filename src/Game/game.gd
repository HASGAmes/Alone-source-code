class_name Game
extends Node2D

signal player_created(player)
var total_turns:int = 0
@export var player_definition: EntityDefinition = preload("res://assets/definitions/entities/actors/player.tres")
const tile_size = 16

@onready var player: Entity
@onready var input_handler: InputHandler = $InputHandler
@onready var map: Map = $Map
@onready var camera: Camera2D = $Camera2D
@onready var prev_player: Entity
@onready var mouse_checker_tile: Node2D = $Map/MouseoverChecker
func new_game() -> void:
	SignalBus.screeneffects = $Map/screeneffects
	player = Entity.new(null, Vector2i.ZERO, "player")
	player.flip_h = true
	SignalBus.player = player
	player_created.emit(player)
	remove_child(camera)
	SignalBus.player_changed.emit(player)
	player.add_child(camera)
	map.generate(player)
	map.update_fov(player.grid_position)
	MessageLog.send_message.bind(
		"Hello and welcome, adventurer, to yet another dungeon!",
		GameColors.WELCOME_TEXT
	).call_deferred()
	camera.make_current.call_deferred()
func load_game() -> bool:
	SignalBus.screeneffects = %"screeneffects"
	player = Entity.new(null, Vector2i.ZERO, "")
	player.flip_h = true
	remove_child(camera)
	player.add_child(camera)
	SignalBus.player_changed.emit(player)
	if not map.load_game(player):
		return false
	player_created.emit(player)
	SignalBus.player = player
	map.update_fov(player.grid_position)
	MessageLog.send_message.bind(
		"Welcome back, adventurer!",
		GameColors.WELCOME_TEXT
	).call_deferred()
	camera.make_current.call_deferred()
	return true
func _physics_process(_delta: float) -> void:
	if player.ai_component!=null:
		var action: Action = await input_handler.get_action(player)
		var enemies_acted:bool = false
		if action:
			randomize()
			if player.fighter_component.turn<100:
				player.fighter_component.turn+=player.fighter_component.quickness
			var previous_player_position: Vector2i = player.grid_position
			while player.fighter_component.turn<100 and player.fighter_component.quickness!=0:
				_handle_enemy_turns()
				player.fighter_component.turn+=player.fighter_component.quickness
				enemies_acted=true
			if action.perform():
				map.update_fov(player.grid_position)
				player.fighter_component.turns_not_in_combat +=1
				player.fighter_component.turn -= 100
			if enemies_acted ==false and player.fighter_component.turn<100:
				_handle_enemy_turns()
			else:
				enemies_acted = false
			total_turns+=1
			for entity in get_map_data().entities:
				if entity.fighter_component:
					entity.passed_turn()
func _handle_enemy_turns() -> void:
	for entity in get_map_data().entities:
		if entity.ai_component != null and entity != player:
			entity.fighter_component.turn += entity.fighter_component.quickness
			print(entity.fighter_component.turn,entity)
			while entity.fighter_component.turn>=100:
				if entity.is_alive():
					entity.ai_component.perform()
				entity.fighter_component.turn -= 100
				entity.fighter_component.turns_not_in_combat +=1
				map.update_fov(player.grid_position)
			

func get_map_data() -> MapData:
	return map.map_data

func body_swap():
	var change:bool = false
	
	var swap_target = get_map_data().get_actor_at_location(mouse_checker_tile._mouse_tile)
	if swap_target != null:
		prev_player = player
		player = swap_target
		SignalBus.player = player
		SignalBus.player_changed.emit(player) 
		player_definition = player._definition
		get_map_data().player = player
		prev_player.remove_child(camera)
		player.add_child(camera)
