extends Control

enum Commands {ITEM, ACTOR,DISMEMBER,REGEN,WOUNDME,RESTART,NUT,STATUS,REALIVE,LV,}
var previous_command=""
var list_of_commands:Array =[]
var list_pos:int = 0
@export var entites:Node2D
@export var game:Node2D
@export var map:Node2D
const KEY_BIND_SYMBOLS := {
	"," : KEY_COMMA, "<" : KEY_LESS,
	"." : KEY_PERIOD, ">" : KEY_GREATER,
	"/" : KEY_SLASH, "?" : KEY_QUESTION,
	";" : KEY_SEMICOLON, ":" : KEY_COLON,
	"\'" : KEY_APOSTROPHE, "\"" : KEY_QUOTEDBL,
	"[" : KEY_BRACELEFT, "{" : KEY_BRACELEFT,
	"]" : KEY_BRACERIGHT, "}" : KEY_BRACERIGHT,
	"-" : KEY_MINUS, "_" : KEY_UNDERSCORE,
	"=" : KEY_EQUAL, "+" : KEY_PLUS,
	"\\" : KEY_BACKSLASH, "|" : KEY_BAR
}
@onready var success: AudioStreamWAV = preload("res://assets/audio/sfx/command_success_Current.wav")
@onready var failed: AudioStreamWAV = preload("res://assets/audio/sfx/command_failed_Current.wav")
@export var enemyDir :String = "res://assets/definitions/entities/actors/"
@export var itemDir :String ="res://assets/definitions/entities/items/"
@export var statusDir: String ="res://assets/definitions/status_effects/"
@export var clearTime :float = 2.0
@onready var nut:AudioStreamMP3 = preload("res://assets/audio/sfx/nut_ZKo5FA9.mp3")
var meme_sound = false

var lineEditRef : LineEdit = null
var config = ConfigFile.new()
var isHeldDown := false
var lastKey : int = -1


func _ready():
	lineEditRef = $CenterContainer/LineEdit
	$ClearTimer.wait_time = clearTime
	#$ClearTimer.connect("timeout",)
	

func _input(event):
	if event.is_action_pressed("COMMAND_LINE") && !isHeldDown:
		visible = !visible
		isHeldDown = true
		if visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			lineEditRef.grab_focus()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		clearText()
	elif event.is_action_released("COMMAND_LINE") && isHeldDown:
		isHeldDown = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		clearText()
	if event.is_action_released("move_up") and !lineEditRef.text == "":
		if list_pos>0:
			list_pos -=1
			var string: Array=[]
			string.append_array(list_of_commands.duplicate())
			lineEditRef.text = string.pop_at(list_pos)
	elif event.is_action_released("move_up") and lineEditRef.text == "":
		var string: Array=[]
		string.append_array(list_of_commands.duplicate())
		if string!=[]:
			lineEditRef.text = string.pop_at(list_pos)
	if event.is_action_released("move_down"):
		if list_pos < list_of_commands.size()-1:
			list_pos+=1
			var string: Array
			string.append_array(list_of_commands.duplicate())
			lineEditRef.text = string.pop_at(list_pos)
	# making sure a bound key only activates once
	if lastKey >= 0 && !Input.is_key_pressed(lastKey):
		lastKey = -1


func parseInputText(text : String):
	text = text.lstrip(" ").rstrip(" ")
	var firstSpace : int = text.find(" ")
	var command : String
	var value : String
	
	if firstSpace == -1:
		command = text
		previous_command = command
		list_of_commands.append(previous_command)
		list_pos = list_of_commands.size()-1
	else:
		command = text.substr(0, firstSpace)
		value = text.substr(firstSpace+1)
		value = value.lstrip(" ")
		
		previous_command = command+" "+ value
		list_of_commands.append(previous_command)
		list_pos = list_of_commands.size()-1
	if runCommand(command, value, getCommandCode(command)) == "":
		
		return

func getCommandCode(command : String) -> int:
	match command.to_lower():
		"item":
			return Commands.ITEM
		"actor":
			return Commands.ACTOR
		"dismember":
			return Commands.DISMEMBER
		"regen":
			return Commands.REGEN
		"woundme":
			return Commands.WOUNDME
		"restart":
			return Commands.RESTART
		"nut":
			return Commands.NUT
		"status":
			return Commands.STATUS
		"realive":
			return Commands.REALIVE
		"lv":
			return Commands.LV
		_:
			clearMessage("Cannot parse " + command + "!",false)
			command = ""
	
	return -1

func runCommand(command : String, value : String, commandCode : int) -> String:
	match commandCode:
		Commands.ITEM:
			spawnEntity(value, itemDir)
		Commands.ACTOR:
			spawnEntity(value, enemyDir)
		Commands.DISMEMBER:
			dismember_debug()
		Commands.REGEN:
			regen_debug()
		Commands.WOUNDME:
			woundme()
		Commands.RESTART:
			clearMessage("Success",true)
			get_tree().reload_current_scene()
		Commands.NUT:
			meme_sound = true
			clearMessage("nut",false)
		Commands.STATUS:
			add_status(value,statusDir)
		Commands.REALIVE:
			realive()
		Commands.LV:
			debug_LV()
		_:
			clearMessage("Cannot parse " + command + "!",false)
			command = ""
	return command
	
func woundme():
	game.player.fighter_component.take_damage(game.player.fighter_component.hp-1,DamageTypes.DAMAGE_TYPES.INTERNAL)
	clearMessage("Success",true)
func realive():
	game.player.fighter_component.reanimate()
	clearMessage("Success",true)
func clearMessage(text : String, passed :bool ,time : float = clearTime):
	lineEditRef.text = text
	print(lineEditRef.text)
	var item_sfx =Itemsfxs.sfx
	if meme_sound ==true:
		item_sfx.set_stream(nut)
		item_sfx.play()
	else:
		if passed == true:
			item_sfx.set_stream(success)
			item_sfx.play()
		else:
			item_sfx.set_stream(failed)
			item_sfx.play()
	$ClearTimer.start(time)
	
func clearText():
	lineEditRef.text = ""
func dismember_debug():
	game.player.fighter_component.body_plan.dismember(true)
	clearMessage("Success",true)
func regen_debug():
	game.player.fighter_component.body_plan.regen_limb()
	clearMessage("Success",true)
func spawnEntity(value : String, path : String):
	var dir = DirAccess
	var file = FileAccess
	var dungeon :MapData = map.map_data
	if !dir.dir_exists_absolute(path):
		clearMessage(path + " does not exist!",true)
		return
	if !file.file_exists(path + value + ".tres"):

		clearMessage(value + ".tres" + " cannot be found!",false)
		return
	
	var entity = load(path + value + ".tres")
	var new_entity: Entity
	new_entity = Entity.new(dungeon, game.player.grid_position + Vector2i(1,1),entity)
	dungeon.entities.append(new_entity)
	entites.add_child(new_entity)
	clearMessage("Successfully spawned " + new_entity.get_entity_name()+"!",true)
	print(dungeon ,"dungeon")
func debug_LV():
	var player = game.player.fighter_component
	player.gain_xp(player.lv*2)
	clearMessage("Success",true)
	return
func add_status(value : String, path : String):
	var dir = DirAccess
	var file = FileAccess
	if value == "clean":
		var status: Array = game.player.status_tracker.get_children()
		status.clear()
		clearMessage("Success",true)
		return
	if !dir.dir_exists_absolute(path):
		clearMessage(path + " does not exist!",true)
		return
#
	if !file.file_exists(path + value + ".tres"):

		clearMessage(value + ".tres" + " cannot be found!",false)
		return
	var status = load(path+value+".tres")
	status = status.duplicate()
	status.proc_chance = 100
	var array:Array[StatusEffectDefinition]
	array = [status]
	game.player.add_status(array)
	clearMessage("Success",true)
func _on_clear_timer_timeout():
	clearText()
	meme_sound = false
	pass # Replace with function body.

func _on_line_edit_text_submitted(text : String):
	parseInputText(text)
	
	pass # Replace with function body.
