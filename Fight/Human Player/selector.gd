extends Spatial

# Selector node - transparent box to show selected objects

const color_move := Color(1, 0, 0, 0.5)
const color_remove := Color(0, 0, 1, 0.5)
const color_change := Color(0.5, 0.5, 0, 0.5)
const color_card_to_play := Color(1, 0, 1, 0.5)

var state_dict = {
	"hide": null,
	"move": color_move,
	"remove": color_remove,
	"change": color_change,
	"card_to_play": color_card_to_play
	}

func move_to(target : Spatial):
	global_transform = target.global_transform

func set_state(state):
	if state == "hide":
		hide()
		return
	show()
	get_child(0).get_surface_material(0).albedo_color = state_dict[state]
