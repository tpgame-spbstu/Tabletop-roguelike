extends Spatial

var _state = null

enum HighlightState {
	HIDEN,
	HIGHLIGHT,
	TAKE_ONE,
	SHOW_COST,
	CANT_TAKE,
	SPIKE,
	TAKE_DAMAGE
}


func set_state(new_state):
	_cancel_highlight()
	match new_state:
		HighlightState.HIDEN:
			pass
		HighlightState.HIGHLIGHT:
			$Highlitght.show()
		HighlightState.TAKE_ONE:
			$TakeOne.show()
		HighlightState.SHOW_COST:
			$TakeOne.show()
			$Cost.show()
		HighlightState.CANT_TAKE:
			$CantTake.show()
		HighlightState.SPIKE:
			$Spike.show()
		HighlightState.TAKE_DAMAGE:
			$TakeDamage.show()
			$Spike.show()
		_:
			return
	_state = new_state


func get_state():
	return _state


func _ready():
	set_state(HighlightState.HIDEN)


func set_highlight():
	set_state(HighlightState.HIGHLIGHT)


func set_take_one():
	set_state(HighlightState.TAKE_ONE)


func set_cost():
	set_state(HighlightState.SHOW_COST)


func set_cant_take():
	set_state(HighlightState.CANT_TAKE)


func set_spike():
	set_state(HighlightState.SPIKE)


func set_take_damage():
	set_state(HighlightState.TAKE_DAMAGE)


func set_hiden():
	set_state(HighlightState.HIDEN)


func _cancel_highlight():
	$Highlitght.hide()
	$TakeOne.hide()
	$Cost.hide()
	$CantTake.hide()
	$TakeDamage.hide()
	$Spike.hide()
