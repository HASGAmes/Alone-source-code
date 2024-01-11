class_name BaseEffect
extends Component

@export var condition:BaseCondition
signal effect_trigger
func _init():
	effect_trigger.connect(effect)
func effect():
	pass
