extends ScrollContainer
@onready var object_cursor :Node2D =%"Editor_Object"


func _ready():
	connect("mouse_entered",mouse_enter)
	connect("mouse_exited",mouse_leave)
	
	
func mouse_enter():
	object_cursor.can_place = false
	object_cursor.hide()
	
	pass
func mouse_leave():
	if visible == true:
		object_cursor.can_place = true
	object_cursor.show()
	pass
