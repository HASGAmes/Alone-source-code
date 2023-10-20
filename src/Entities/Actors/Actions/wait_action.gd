class_name WaitAction
extends Action

func perform() -> bool:
	entity.move(Vector2i.ZERO)
	return true
