extends Spatial

var energy_full_color = Color8(236,183,24)
var epty_color = Color8(188,188,188)
var bones_full_color = Color8(16,16,31)
var blood_full_color = Color8(225,35,35)

var energy_count = 7
var bones_count = 5
var blood_count = 5

var gems_scale = Vector3(0.1, 0.1, 0.1)
var space = Vector3(-0.15 ,0, 0)
var energy_start_pos = Vector3(-2.594,0,-1.04)
var bones_start_pos = Vector3(-2.594,0,-1.377)
var blood_start_pos = Vector3(-2.594,0,-1.714)


var t_mesh = preload("res://Models/Scene/gems_mesh.tres")


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
		
		
func add_energy_to_scene():
	for i in range(energy_count):
		var temp = MeshInstance.new()
		temp.mesh = t_mesh
		var t_material = SpatialMaterial.new()
		temp.set_surface_material(0,t_material)
		temp.scale = gems_scale
		$energy_status.add_child(temp)
		temp.translation = energy_start_pos + space * i
		
func add_bones_to_scene():
	for i in range(bones_count):
		var temp = MeshInstance.new()
		temp.mesh = t_mesh
		var t_material = SpatialMaterial.new()
		temp.set_surface_material(0,t_material)
		temp.scale = gems_scale
		$bones_status.add_child(temp)
		temp.translation = bones_start_pos + space * i

func add_blood_to_scene():
	for i in range(blood_count):
		var temp = MeshInstance.new()
		temp.mesh = t_mesh
		var t_material = SpatialMaterial.new()
		temp.set_surface_material(0,t_material)
		temp.scale = gems_scale
		$blood_status.add_child(temp)
		temp.translation = blood_start_pos + space * i
	
func _ready():
	add_energy_to_scene()
	add_bones_to_scene()
	add_blood_to_scene()
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
	
	
