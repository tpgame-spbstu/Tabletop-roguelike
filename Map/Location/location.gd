extends Spatial


var deck_config
var inventory_config
var params
signal return_to_map(is_win)

func initialize(deck_config, inventory_config, params : Dictionary):
	self.deck_config = deck_config
	self.inventory_config = inventory_config
	self.params = params
