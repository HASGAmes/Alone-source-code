class_name Skills_Definition
extends Resource
@export_category("Skill parameters")
@export var skill_range :int
@export var skill_name :String="unnamed skill"
@export var skill_power:int
@export var skill_cooldown:int
@export var free_move:bool = false
@export var skill_buff:bool = false
@export var skill_message="%s uses %s"
@export var message_color:Color =Color.WHITE
@export var skill_icon:AtlasTexture = preload("res://assets/resources/place_holder_skill.tres")
