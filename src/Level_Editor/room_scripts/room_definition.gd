class_name RoomResource
extends Resource

@export_category("Room size")
@export_range(3,20) var room_width:int = 3
@export_range(3,20) var room_height:int = 3
@export_category("Entities and tiles")
@export var tiles_contained:Array[Tile]
@export var entities_contained:Array[Entity]
