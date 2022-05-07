extends Spatial

var energy_full_color = Color8(236,183,24)
var epty_color = Color8(188,188,188)
var bones_full_color = Color8(16,16,31)

var bones_count = 7

func energy_null() :
	var energy_child = $energy_status.get_children()
	for i in energy_child:
		i.get_active_material(0).albedo_color = epty_color
	
	
func bones_null() :
	var bones_child = $bones_status.get_children()
	for i in bones_child:
		i.get_active_material(0).albedo_color = epty_color
		
	
func blood_null() :
	var blood_child = $blood_status.get_children()
	for i in blood_child:
		i.get_active_material(0).albedo_color = epty_color
	
func _ready():
	bones_null()
	blood_null()

func _on_human_player_state_energy_changed(energy):
	energy_null()
	var energy_child = $energy_status.get_children()
	for i in range(energy):
		energy_child[i].get_active_material(0).albedo_color = energy_full_color
	
	

func _on_human_player_state_bones_changed(bones):
	bones_null()
	var bones_child = $bones_status.get_children()
	for i in range(bones):
		bones_child[i].get_active_material(0).albedo_color = bones_full_color
	
