extends Reference

# MapConfig class - class for storing map configuration

var current_map_point_config
var map_point_graph: Dictionary
# array of visited map points
var _visited = Array() setget add_visited, get_visited


func add_visited(map_point, animate: bool=true):
	_visited.push_back(map_point)
	map_point.mark_visited(animate)


func get_visited() -> Array:
	return _visited