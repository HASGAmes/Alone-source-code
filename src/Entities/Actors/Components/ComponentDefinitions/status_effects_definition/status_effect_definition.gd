##The base status definition where all status get the basic variable that they will all need
##
class_name StatusEffectDefinition
extends Resource

@export_category("Status stats")
@export var status_name :String = "unnamed status"##name of the status
@export var turns:int##how long a status last
@export var is_indefinite:bool = false##whether or not a status ends.be careful with this one
@export_range(0,100) var proc_chance:int##how likely ranging from 0% to 100% a status will proc
@export var can_stack:bool = false##if false a actor can't have the same status twice
