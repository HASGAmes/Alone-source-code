@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("MyButton", "Button", preload("mybutton.gd"), preload("icon.svg"))
	# Initialization of the plugin goes here.
	pass


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_custom_type("MyButton")
	pass
