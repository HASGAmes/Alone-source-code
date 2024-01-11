extends TabContainer

@onready var object_cursor :Node2D =%"Editor_Object"
func _ready():
	SignalBus.editor_open = !SignalBus.editor_open
	visible = !SignalBus.editor_open
	%"CheckButton".visible = visible
	get_node("/root/GameManager/InterfaceRoot/InfoBar").visible = SignalBus.editor_open
	get_node("/root/GameManager/InterfaceRoot/VBoxContainer/gamebox/HBoxContainer").visible = SignalBus.editor_open
func _process(delta):
	if Input.is_action_just_pressed("toggle editor"):
		SignalBus.editor_open = !SignalBus.editor_open
		visible = !SignalBus.editor_open
		%"CheckButton".visible = visible
		get_node("/root/GameManager/InterfaceRoot/InfoBar").visible = SignalBus.editor_open
		get_node("/root/GameManager/InterfaceRoot/VBoxContainer/gamebox/HBoxContainer").visible = SignalBus.editor_open
func _on_mouse_entered():
	object_cursor.can_place = false
	object_cursor.hide()
	pass # Replace with function body.


func _on_mouse_exited():
	if visible == true:
		object_cursor.can_place = true
	object_cursor.show()
	pass # Replace with function body.
