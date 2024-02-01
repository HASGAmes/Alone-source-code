extends Node

signal player_died
signal message_sent(text, color)
signal player_changed(player)
var player:Entity
signal escape_requested
var editor_open = false
var screeneffects:CanvasModulate
var iseeall = false
signal attacked(entity,target)
signal critted(entity,target)
signal missed(entity,target)
var actor_types:Dictionary
var item_types:Dictionary
var tile_types:Dictionary
