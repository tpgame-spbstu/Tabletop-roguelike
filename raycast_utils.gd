extends Object

class_name RaycastUtils

static func is_mouse_hovered_on_area(area: Area, collision_layer_index: int, cam: Camera, world: World, mouse_pos: Vector2):
	var ray_from = cam.project_ray_origin(mouse_pos)
	var RAY_LENGTH = 100000
	var ray_to = ray_from + cam.project_ray_normal(mouse_pos) * RAY_LENGTH
	var space_state = world.direct_space_state

	var raycast_result = space_state.intersect_ray(
		ray_from,  # from
		ray_to,  # to
		[],  # exclude
		get_collision_layer_mask(collision_layer_index),  # collision layer of the ray
		false,  # collide with bodies
		true  # collide with areas
	)
	return raycast_result and raycast_result['collider'] == area


static func get_collision_layer_mask(collision_layer_index):
	return 1 << (collision_layer_index - 1)
