class_name FighterComponentDefinition
extends Resource

@export_category("Stats")
@export var max_hp: int = 20
@export var str:int= 10
@export var dex:int = 10
@export var toughness:int= 10
@export var will:int= 10
@export var prescence:int
@export_category("Advanced_Stats")
@export var dismember_chance:int = 0
@export var decap:bool = false
@export var power: int = 0
@export var quickness:int = 100
@export var defense: int = 0
@export_range(-21,21) var hit_chance: int
@export_range(-21,21) var DV: int
@export_range(-21,21) var critdam:int
@export var on_hit_effects:Array[StatusEffectDefinition]
@export_category("AI aggression and hunger")
@export_range(-200,200) var aggression:int 
@export var max_hunger:int = 100
@export_category("Resistances and Weaknesses")
@export var res:Array[DamageTypes.DAMAGE_TYPES]
@export var weakness:Array[DamageTypes.DAMAGE_TYPES]
@export var immunity:Array[DamageTypes.DAMAGE_TYPES]
@export_category("Loot table")
@export var items_on_death:Array[EntityDefinition]
@export_category("Visuals")
@export var death_texture: AtlasTexture = preload("res://assets/resources/default_death_texture.tres")
@export var death_color: Color = Color.DARK_RED
@export var corpse_food:FoodConsumableDefinition = load("res://assets/definitions/entities/items/corpse_food.tres")
@export_category("Audio")
@export var death_noise: Array[AudioStreamWAV] = [preload("res://assets/audio/sfx/ahhhh.wav")]
@export_category("Body_Plan and Skills")
@export var body_plan_definition: Body_Plan_Definition
var body_plan_def :Body_Plan_Definition
@export var skills:Array[Skills_Definition]
