extends Spatial

var energy_full_color = Color8(236,183,24)
var epty_color = Color8(188,188,188)
var bones_full_color = Color8(16,16,31)

func energy_null() :
	$energy_status/energy1.get_active_material(0).albedo_color = epty_color
	$energy_status/energy2.get_active_material(0).albedo_color = epty_color
	$energy_status/energy3.get_active_material(0).albedo_color = epty_color
	$energy_status/energy4.get_active_material(0).albedo_color = epty_color
	$energy_status/energy5.get_active_material(0).albedo_color = epty_color
	$energy_status/energy6.get_active_material(0).albedo_color = epty_color
	$energy_status/energy7.get_active_material(0).albedo_color = epty_color
	
	
func bones_null() :
	$bones_status/bone1.get_active_material(0).albedo_color = epty_color
	$bones_status/bone2.get_active_material(0).albedo_color = epty_color
	$bones_status/bone3.get_active_material(0).albedo_color = epty_color
	$bones_status/bone4.get_active_material(0).albedo_color = epty_color
	$bones_status/bone5.get_active_material(0).albedo_color = epty_color
	$bones_status/bone6.get_active_material(0).albedo_color = epty_color
	$bones_status/bone7.get_active_material(0).albedo_color = epty_color
	
func blood_null() :
	$blood_status/blood1.get_active_material(0).albedo_color = epty_color
	$blood_status/blood2.get_active_material(0).albedo_color = epty_color
	$blood_status/blood3.get_active_material(0).albedo_color = epty_color
	$blood_status/blood4.get_active_material(0).albedo_color = epty_color
	$blood_status/blood5.get_active_material(0).albedo_color = epty_color
	$blood_status/blood6.get_active_material(0).albedo_color = epty_color
	$blood_status/blood7.get_active_material(0).albedo_color = epty_color
	
func _ready():
	bones_null()
	blood_null()

func _on_human_player_state_energy_changed(energy):
	energy_null()
	if (energy>=1):
		$energy_status/energy1.get_active_material(0).albedo_color = energy_full_color
	if (energy>=2):
		$energy_status/energy2.get_active_material(0).albedo_color = energy_full_color
	if (energy>=3):
		$energy_status/energy3.get_active_material(0).albedo_color = energy_full_color
	if (energy>=4):
		$energy_status/energy4.get_active_material(0).albedo_color = energy_full_color
	if (energy>=5):
		$energy_status/energy5.get_active_material(0).albedo_color = energy_full_color
	if (energy>=6):
		$energy_status/energy6.get_active_material(0).albedo_color = energy_full_color
	if (energy>=7):
		$energy_status/energy7.get_active_material(0).albedo_color = energy_full_color
	


func _on_human_player_state_bones_changed(bones):
	bones_null()
	if (bones>=1):
		$bones_status/bone1.get_active_material(0).albedo_color = bones_full_color
	if (bones>=2):
		$bones_status/bone2.get_active_material(0).albedo_color = bones_full_color
	if (bones>=3):
		$bones_status/bone3.get_active_material(0).albedo_color = bones_full_color
	if (bones>=4):
		$bones_status/bone4.get_active_material(0).albedo_color = bones_full_color
	if (bones>=5):
		$bones_status/bone5.get_active_material(0).albedo_color = bones_full_color
	if (bones>=6):
		$bones_status/bone6.get_active_material(0).albedo_color = bones_full_color
	if (bones>=7):
		$bones_status/bone7.get_active_material(0).albedo_color = bones_full_color
	
