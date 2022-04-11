extends Area2D

signal _mouse_entered(card)
signal _mouse_exited(card)

var size: Vector2 setget ,get_size
onready var sprite : Sprite = $Sprite


func _ready():
    # get the size of the card viewport and set its size to the viewport on this scene
    size = get_node("Viewport/card/card_visuals/Viewport").get_size()
    $Viewport.set_size(size)

    # for checks on collisions with mouse
    var coll_shape = CollisionPolygon2D.new()
    coll_shape.set_polygon(_get_points())
    add_child(coll_shape)
    # set the mask to prevent from colliding with other cards
    set_collision_mask_bit(1, false)
    set_collision_mask_bit(2, true)
    # to get mouse events
    set_pickable(true)

    connect("mouse_entered", self, "_on_mouse_enter")
    connect("mouse_exited", self, "_on_mouse_exit")


"""
    Get the points of the card's rectangle
        rotate the RIGTH (1, 0) vector, multiplied by half of the card's hypot,
"""
func _get_points() -> PoolVector2Array:
    var pos := get_position()
    var _size: Vector2 = get_size()
    var phi := _size.angle()
    var length := _size.length() / 2
    var points: PoolVector2Array

    # get the 4 points of the card's rectangle
    # clockwise
    for psi in [phi, PI - phi, phi + PI, -phi]:
        points.push_back(pos + Vector2.RIGHT.rotated(psi) * length)
    return points


func _on_mouse_enter():
    # place on top of other cards
    # set_z_index(1)
    emit_signal("_mouse_entered", self)


func _on_mouse_exit():
    emit_signal("_mouse_exited", self)
    # set_z_index(0)


func get_size() -> Vector2:
    return size * get_scale()

