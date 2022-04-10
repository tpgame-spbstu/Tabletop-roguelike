extends Node2D


func _ready():
    # get the size of the card viewport and set its size to the viewport on this scene
    $Viewport.set_size(get_node("Viewport/card/card_visuals/Viewport").get_size())
    # print($Viewport.get_size())
