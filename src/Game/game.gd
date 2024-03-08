class_name Game
extends Node2D

signal player_created(player)
var total_turns:int = 0
@export var player_definition: EntityDefinition = preload("res://assets/definitions/entities/actors/player.tres")
const tile_size = 16
var actor_turn_queue:Array[Entity]
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
	SignalBus.player = player
	SignalBus.player_changed.emit(player)
	if not map.load_game(player):
		return false
	player_created.emit(player)
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
			##while the turn value is below 100 add quickness to it
			while player.fighter_component.turn<100:
				player.fighter_component.turn+=player.fighter_component.quickness
				## if it still isn't 100 then enemies get their turn
				if player.fighter_component.turn<100:
					enemies_acted = true
					_handle_turns()
			## if it is over 100 then they get to act out the chose action
			if player.fighter_component.turn>=100:
				action.perform()
				player.fighter_component.turn -=100
			if enemies_acted == false:
				_handle_turns()
			total_turns+=1
			map.update_fov(player.grid_position)
			print(player.get_entity_name(),player.fighter_component.turn)
			var previous_player_position: Vector2i = player.grid_position
			print(player.fighter_component.turn,"curen")
			for entity in get_map_data().entities:
				if entity.fighter_component:
					entity.passed_turn()
##handles all turns that aren't the players
##this way the player chooses what action they will do first
##but doesn't been that they can move first
func _handle_turns() -> void:
	for entity in get_map_data().entities:
		if entity.ai_component != null:
			if entity.fighter_component.turn<100:
				entity.fighter_component.turn += entity.fighter_component.quickness
			if entity.fighter_component.turn>=100:
				if entity.is_alive():
					if entity != player:
						entity.ai_component.perform()
					entity.fighter_component.turns_not_in_combat +=1
					entity.fighter_component.turn-=100
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
