extends Node

signal player_died
signal message_sent(text, color)
signal player_changed(player)
var player:Entity
signal escape_requested
var editor_open = false
var screeneffects:CanvasModulate
var iseeall = false
signal attacked(entity)
signal critted(entity)
signal missed(entity)
