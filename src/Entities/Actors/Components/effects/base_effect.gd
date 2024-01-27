class_name BaseEffect
extends Component

var effect_message
signal effect_trigger
func _init(defition:BaseEffectDefinition):
	effect_message = defition.effect_message
	effect_trigger.connect(effect)
func effect():
	pass
