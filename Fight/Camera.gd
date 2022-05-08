extends Camera

enum {DECK_POSITION, HAND_POSITION, BOARD_POSITION, BELL_POSITION, ENEMY_POSITION}

var deck_position
var hand_position
var board_position
var bell_position
var enemy_position
var current_position = BOARD_POSITION

var _trauma = 0.0  # current shake strength
var _trauma_power = 2  # trauma exponent. Use [2, 3]
onready var _noise = OpenSimplexNoise.new()
var _noise_y = 0  # second coord in getting the noise
var _pos_to_return = null  # original transform before shaking

export(float, 0, 1, 0.01) var decay = 0.7  # how quickly the shaking stops [0, 1]
export(Vector3) var max_offset = Vector3(3, 3, 3)  # maximum x\y\z shake
export(float, 0, 0.8, 0.01) var max_pitch = 0.1  # x rot in rads
export(float, 0, 0.8, 0.01) var max_yaw = 0.1  # y rot in rads
export(float, 0, 0.8, 0.01) var max_roll = 0.1  # z rot in rads
export(int, 1, 128, 1) var period = 4  # lower -> higher-frequency noise
export(int, 1, 9, 1) var octaves = 2  # higher -> more detailed noise, more time to generate
export(float, 0.4, 1, 0.05) var def_trauma = 0.75


func _ready():
	deck_position = get_parent().get_node("camera_positions/camera_deck_position").transform
	hand_position = get_parent().get_node("camera_positions/camera_hand_position").transform
	board_position = get_parent().get_node("camera_positions/camera_board_position").transform
	bell_position = get_parent().get_node("camera_positions/camera_bell_position").transform
	enemy_position = get_parent().get_node("camera_positions/camera_enemy_position").transform
	transform = board_position

	# set the noise up
	randomize()
	_noise.seed = randi()
	_noise.period = period
	_noise.octaves = octaves


func _process(delta):
	# if someone wants to make the camera shaking
	if _trauma:
		# save the original translation
		if not _pos_to_return:
			_pos_to_return = get_global_transform()
		# linearly reduce the trauma
		_trauma = max(_trauma - decay * delta, 0)
		_shake()
	# aha, the _trauma has ended, return the camera to its
	# saved transform
	elif _pos_to_return:
		set_global_transform(_pos_to_return)
		_pos_to_return = null


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


## sets the camera into shaking
func add_trauma(amount=def_trauma):
	_trauma = amount


func set_camera_position(new_position):
	var animation = LinMoveAnimation.new(transform, 
		new_position, 0.1, self)
	AnimationManager.add_animation(animation)
	yield(animation, "animation_ended")


func _shake():
	var amount = pow(_trauma, _trauma_power)
	_noise_y += 1
	# Using noise
	var rot = Vector3.ZERO
	rot.x = max_pitch * amount * _noise.get_noise_2d(_noise.seed, _noise_y)
	rot.y = max_yaw * amount * _noise.get_noise_2d(_noise.seed + 1, _noise_y)
	rot.z = max_roll * amount * _noise.get_noise_2d(_noise.seed + 2, _noise_y)
	var trans = Vector3.ZERO
	trans.x = max_offset.x * amount * _noise.get_noise_2d(_noise.seed + 3, _noise_y)
	trans.y = max_offset.y * amount * _noise.get_noise_2d(_noise.seed + 4, _noise_y)
	trans.z = max_offset.z * amount * _noise.get_noise_2d(_noise.seed + 5, _noise_y)

	set_rotation(_pos_to_return.basis.get_euler() + rot)
	set_translation(_pos_to_return.origin + trans)
