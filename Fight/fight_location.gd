extends "res://location.gd"

var CardConfig := preload("res://Card/card_config.gd")
var DeckConfig := preload("res://deck_config.gd")
onready var selector : Spatial = get_node("selector")



const color_move := Color(1, 0, 0, 0.5)
const color_add := Color(0, 1, 0, 0.5)
const color_remove := Color(0, 0, 1, 0.5)
const color_change := Color(0.5, 0.5, 0, 0.5)

var is_anim = false

class MoveTool:
	extends Reference
	var fight_location
	func _init(fight_location):
		self.fight_location = fight_location
	
	var selected_card : Spatial = null
	
	func _on_board_click(cell, card):
		if selected_card == null:
			if card != null:
				selected_card = card
		else:
			if card != null:
				return
			var prev_cell = selected_card.get_parent()
			selected_card.animation = LinMoveAnimation.new(prev_cell.global_transform, 
				cell.global_transform, 2, selected_card)
			print("anim_start")
			fight_location.is_anim = true
			yield(selected_card, "animation_ended")
			fight_location.is_anim = false
			print("anim_end")
			prev_cell.remove_child(selected_card)
			
			cell.add_child(selected_card)
			selected_card.translate_object_local(-selected_card.translation)
			selected_card = null

class AddTool:
	extends Reference
	var fight_location
	func _init(fight_location):
		self.fight_location = fight_location
	
	var CardScene := load("res://Card/card.tscn") as PackedScene
	
	func _on_board_click(cell, card):
		if card != null:
			return
		var new_card = CardScene.instance()
		new_card.name = "card"
		cell.add_child(new_card)
		new_card.initialize(fight_location.deck_config.cards[0], "player 1")

class RemoveTool:
	extends Reference
	
	func _on_board_click(cell, card):
		if card != null:
			cell.remove_child(card)
			card.queue_free()


class ChangeTool:
	extends Reference
	func _on_board_click(cell, card):
		pass



var card_tool = null

func initialize(deck_config , inventory_config , params : Dictionary):
	.initialize(deck_config , inventory_config , params)
	self.deck_config = DeckConfig.new()
	self.deck_config.cards.append(CardConfig.new(
		"Карта 1", "цена", [], 3, 2, 1, "range", 1
		))
	$board.initialize(self)

func _ready():
	pass

func _on_board_click(cell, card):
	if is_anim:
		return
	print(cell.row_index, " ", cell.cell_index)
	selector.global_translate(cell.to_global(Vector3.ZERO) - selector.to_global(Vector3.ZERO))
	if card_tool != null:
		card_tool._on_board_click(cell, card)



class LinMoveAnimation:
	
	var start_transform : Transform
	var end_transform : Transform
	var speed : float
	var spatial : Spatial
	var progress : float = 0.0
	
	
	func _init(start_transform : Transform, end_transform : Transform, speed : float, spatial : Spatial):
		self.start_transform = start_transform
		self.end_transform = end_transform
		self.speed = speed
		self.spatial = spatial
	
	func process(delta : float) -> bool:
		progress += delta * speed
		if progress >= 1.0:
			progress = 1.0
		spatial.global_transform = start_transform.interpolate_with(end_transform, progress)
		if progress == 1.0:
			return true
		return false


func _on_button_move_pressed():
	card_tool = MoveTool.new(self)
	selector.get_node("MeshInstance").get_surface_material(0).albedo_color = color_move


func _on_button_add_pressed():
	card_tool = AddTool.new(self)
	selector.get_node("MeshInstance").get_surface_material(0).albedo_color = color_add


func _on_button_remove_pressed():
	card_tool = RemoveTool.new()
	selector.get_node("MeshInstance").get_surface_material(0).albedo_color = color_remove


func _on_button_change_pressed():
	card_tool = ChangeTool.new()
	selector.get_node("MeshInstance").get_surface_material(0).albedo_color = color_change


func _on_button_exit_to_map_pressed():
	emit_signal("return_to_map")
