extends MarginContainer

@onready var hp_bar: ProgressBar = $"%HpBar"
@onready var hp_label: Label = $"%HpLabel"

var prev_player:Entity
func initialize(player: Entity) -> void:
	await ready
	SignalBus.player_changed.connect(connect_player)
	connect_player(player)

func connect_player(player:Entity) ->void:
	if prev_player!=null:
		prev_player.fighter_component.hp_changed.disconnect(player_hp_changed)
	player.fighter_component.hp_changed.connect(player_hp_changed)
	var player_hp: int = player.fighter_component.hp
	var player_max_hp: int = player.fighter_component.max_hp
	player_hp_changed(player_hp, player_max_hp)
	prev_player = player
func player_hp_changed(hp: int, max_hp: int) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	hp_label.text = "HP: %d/%d" % [hp, max_hp]
