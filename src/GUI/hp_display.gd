extends MarginContainer

@onready var hp_bar: ProgressBar = $"%HpBar"
@onready var hp_label: Label = $"%HpLabel"
@onready var hunger_label:Label = $"HungerLabel"
var prev_player:Entity
func initialize(player: Entity) -> void:
	#await ready
	
	if player==null:
		player = SignalBus.player
	SignalBus.player_changed.connect(connect_player)
	connect_player(player)

func connect_player(player:Entity) ->void:
	if prev_player!=null:
		prev_player.fighter_component.hp_changed.disconnect(player_hp_changed)
	player.fighter_component.hp_changed.connect(player_hp_changed)
	player.fighter_component.hunger_changed.connect(player_hunger_changed)
	var player_hp: int = player.fighter_component.hp
	var player_max_hp: int = player.fighter_component.max_hp
	var player_hunger:int = player.fighter_component.hunger
	var player_max_hunger:int = player.fighter_component.max_hunger
	player_hp_changed(player_hp, player_max_hp)
	player_hunger_changed(player_hunger,player_max_hunger)
	prev_player = player
func player_hp_changed(hp: int, max_hp: int) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	hp_label.text = "HP: %d/%d" % [hp, max_hp]
func player_hunger_changed(hunger:int,max_hunger:int)-> void:
	if hunger>0:
		hunger_label.text = "Satiated"
	elif hunger<=0 and hunger>-100:
		hunger_label.text = "Hunger"
	elif hunger<=-100 and hunger>-200:
		hunger_label.text = "Starving"
	elif hunger<=-200:
		hunger_label.text = "Famished"
