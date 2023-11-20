extends Button
var current_limb:Limb_Component
func focuses()->bool:
	if focus_entered:
		return true
	else:
		return false
