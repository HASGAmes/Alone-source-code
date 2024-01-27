##This is used to fill out stats and other goodies for an entity's fight component
class_name FighterComponentDefinition
extends Resource

@export_group("Stats")
@export var max_hp: int = 20##max hp of a entity
@export var str:int = 10##strength of a entity
@export var dex:int= 10##dexitery of a entity
@export var toughness:int= 10##toughness of a entity
@export var will:int= 10##will of a entity
@export var prescence:int##currently doesn't have use
@export_group("Advanced_Stats")
@export var dismember_chance:int = 0## the chance to sever limbs on hit
@export var decap:bool = false##decides if removing important limbs is a option
@export var power: int = 0##was the attack but has been replace will be bonus damage
##how fast a entity can perform their turn.players always get to decide how to move before anything else
##In order to act you must get the turn var to at least 100 before you can make
## another action if it is less you pass turns till it is if it is above 100 you 
## keep the leftover to next turn which lets you act before other actors
@export var quickness:int = 100
@export var defense: int = 0##protects against damage like damage - defense
@export_range(-21,21,1,"or_greater", "or_less") var hit_chance: int## hits roll a d20 and this is the bonus
@export_range(-21,21,1,"or_greater", "or_less") var DV: int = 0##what hits roll against
@export_range(-21,21,1,"or_greater", "or_less") var critdam:int = 0##changes what you need for a crit
@export_range(0,100,1,"or_greater", "or_less") var base_offhand_attack_change = 1##the chance for offhand attacks
@export var on_hit_effects:Array[StatusEffectDefinition]##list of on hit status
@export_group("AI aggression and hunger")
@export_range(-200,200,1,"or_greater", "or_less") var aggression:int =0##how likely something is to attack
@export var max_hunger:int = 100## hunger of a entity. Affects aggression
@export_group("Resistances and Weaknesses")
@export var res:Array[DamageTypes.DAMAGE_TYPES]##entities take half damage from these
@export var weakness:Array[DamageTypes.DAMAGE_TYPES]##entities take twice damage from these
@export var immunity:Array[DamageTypes.DAMAGE_TYPES]##entities take no damage from these
@export_group("Loot table")
@export var items_on_death:Array[EntityDefinition]## a list of all the stuff a entity can drop
@export_group("Visuals")
## death texture on death
@export var death_texture: AtlasTexture = preload("res://assets/resources/default_death_texture.tres")
## death color on death
@export var death_color: Color = Color.DARK_RED
## this is what effects eating a corpse of the formly alive actor will have
@export var corpse_food:FoodConsumableDefinition = load("res://assets/definitions/entities/items/corpse_food.tres")
@export_group("Audio")
## the noise a entity makes on death. can be left empty
@export var death_noise: Array[AudioStreamWAV] = [preload("res://assets/audio/sfx/ahhhh.wav")]
@export_group("Body_Plan and Skills")
## this defines what parts entities have
@export var body_plan_definition: Body_Plan_Definition
var body_plan_def :Body_Plan_Definition
## this is a list of skills entities start with
@export var skills:Array[Skills_Definition]