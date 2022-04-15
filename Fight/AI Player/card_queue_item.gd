extends Reference

class_name CardQueueItem

# CardQueueItem class - item of card queue, that tells what card to play, when and where 

var card_config
var loop_number
var column_index


func _init(card_config, loop_number, column_index):
	self.card_config = card_config
	self.loop_number = loop_number
	self.column_index = column_index
