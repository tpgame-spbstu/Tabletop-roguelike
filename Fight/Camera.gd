extends Camera

enum {DECK_POSITION, HAND_POSITION, BOARD_POSITION, BELL_POSITION, ENEMY_POSITION}

var deck_position
var hand_position
var board_position
var bell_position
var enemy_position
var current_position = BOARD_POSITION

func _ready():
	deck_position = get_parent().get_node("camera_positions/camera_deck_position").transform
	hand_position = get_parent().get_node("camera_positions/camera_hand_position").transform
	board_position = get_parent().get_node("camera_positions/camera_board_position").transform
	bell_position = get_parent().get_node("camera_positions/camera_bell_position").transform
	enemy_position = get_parent().get_node("camera_positions/camera_enemy_position").transform
	transform = board_position

func set_camera_position(new_position):
	var animation = LinMoveAnimation.new(transform, 
		new_position, 0.1, self)
	AnimationManager.add_animation(animation)
	yield(animation, "animation_ended")
	

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_LEFT:
			if current_position == BELL_POSITION:
				set_camera_position(board_position)
				current_position = BOARD_POSITION
			else:
				set_camera_position(deck_position)
				current_position = DECK_POSITION
		if event.scancode == KEY_UP:
			if current_position == HAND_POSITION:
				set_camera_position(board_position)
				current_position = BOARD_POSITION
			else:
				set_camera_position(enemy_position)
				current_position = ENEMY_POSITION
		if event.scancode == KEY_RIGHT:
			if current_position == DECK_POSITION:
				set_camera_position(board_position)
				current_position = BOARD_POSITION
			else:
				set_camera_position(bell_position)
				current_position = BELL_POSITION
		if event.scancode == KEY_DOWN:
			if current_position == ENEMY_POSITION:
				set_camera_position(board_position)
				current_position = BOARD_POSITION
			else:
				set_camera_position(hand_position)
				current_position = HAND_POSITION
		



func _on_human_player_1_card_to_play_selected(card):
	set_camera_position(board_position)
	current_position = BOARD_POSITION
