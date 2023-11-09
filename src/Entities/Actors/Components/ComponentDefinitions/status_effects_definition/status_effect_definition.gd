class_name StatusEffectDefinition
extends Resource

@export_category("Status stats")
@export var status_name :String = "unnamed status"
@export var turns:int
@export var is_indefinite:bool = false
@export_range(0,100) var proc_chance:int
@export var can_stack:bool = false
