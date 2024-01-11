##This sets up the body plan so the actually script can load it in
class_name Body_Plan_Definition
extends Resource

@export_category("Body parts")
@export var limbs_are_alive:bool = false## if true when a entity has a limb severed it comes to life
@export var body_parts: Array[Limb_Definition]## list of parts attached
var amount_of_important_limbs: int ##number of important limbs like ya head
enum TYPE_OF_PARTS{HEAD,TORSE,ARM,LEG,FEET,HAND,FACE,BACK}## this effects equipment slots
