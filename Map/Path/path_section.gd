extends Spatial

func get_mesh() -> MeshInstance:
	return get_node("path_sec_body") as MeshInstance
