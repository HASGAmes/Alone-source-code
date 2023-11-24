
class_name MapMaker
extends EditorPlugin

var entities:Array[EntityDefinition]
var tiles:Array[TileDefinition]
@onready var enemyDir :String = "res://assets/definitions/entities/actors/"
@onready var itemDir :String ="res://assets/definitions/entities/items/"
@onready var tileDir :String = "res://assets/definitions/tiles/"
func _process(delta):
	if Engine.is_editor_hint():
		# Code to execute in editor.
		
