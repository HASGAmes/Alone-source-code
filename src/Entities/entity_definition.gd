##Blue prints of entities. you can fill these out to easily make a actor, item or anything inbetween
#@icon("res://assets/resources/resource_icons/entity_icon.svg")
class_name EntityDefinition
extends Resource

@export_category("Visuals")
@export var name: String = "Unnamed Entity"## the name of a entity, left blank is a Unnamed Entity
@export var texture: AtlasTexture = preload("res://assets/resources/entitydefault.tres")## for this you need a atlas texture which like a sprite sheet then you set the size to 16 and you got the texture
@export_color_no_alpha var color: Color = Color.WHITE## This changes the color which is white by default
##this is for the description of a blurb for entities. The default is a reference to caves of qud may be changed later
@export_placeholder("A hideous specimen") var entity_blurb:String ="A hideous specimen"
@export_category("Mechanics")
@export var is_blocking_movment: bool = true## Changes if they can block movement
@export var type: Entity.EntityType## If it is a Actor(alive and moves),item or a corpse
@export var starting_movement:Entity.MOVEMENT_TYPE = Entity.MOVEMENT_TYPE.WALK##changes the starting movement mode

@export_category("Components")
@export var fighter_definition: FighterComponentDefinition##loads a fightcomponent for actors
@export var ai_type: Entity.AIType## only for actors uses a script to attach a ai for moving
@export var item_definition: ItemComponentDefinition##definition for entity items
@export var inventory_capacity: int = 0##amount a entity can hold
@export var starting_status:Array[StatusEffectDefinition]

