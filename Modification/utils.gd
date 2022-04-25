# -15 degrees
const PHI := -6.2830 / 24
# coeff to put the cards on the edges lower, than the cards in the middle
const FUNC_COEFF := 7.5

## Get the line coeffs of the least squares regression line
##
## @desc: in order to find the centerline of the custom convex hull
##        use the regression line as the "median" for all the points
##        -> the center line
##
## @warn: operates on the vertical axis, not on the horizontal one!
##        for rectangle the result is |, not －
##
##
## :poly: the points of a convex hull for which to find the center line
##
## :return: coeffs of the regression line (=center line)
func least_squares_regression(poly: PoolVector2Array) -> Vector2:
	var _x = 0  # average of x
	var _y = 0  # average of y
	var _xy = 0  # average of x and y multiplication
	var _x2 = 0  # average of squares of x
	var _y2 = 0  # average of squares of y
	var n = 0  # number of points
	for p in poly:
		_x += p.x
		_y += p.y
		_xy += p.x*p.y
		_x2 += pow(p.x, 2)
		_y2 += pow(p.y, 2)
		n += 1
	var line_coeffs: Vector2
	line_coeffs.x = (n * _xy - _x * _y) / (n * _y2 - pow(_y, 2))
	line_coeffs.y = (_x - line_coeffs.x * _y) / n
	return line_coeffs


## Get the "line sign"
##
## @desc: determines whether the point is above, on, under the 2d line
##
##
## :line_coeffs: coeffs of the line (k and b in y = kx + b)
## :point: point for which to get the "line sign"
## 
## :return: <0, if point is under the line
##           0, if point is on the line
##          >0, if points is above the line
func get_line_sign(line_coeffs: Vector2, point: Vector2):
	return point.y * line_coeffs.x + line_coeffs.y - point.x


func _f(x, coeff=60.0):
	return pow(x, 2) / coeff


## get the position (translation vector) and the angle (in rad) to rotate
##
## :phlds: array of placeholders
## :get_last: if true, get only the last placements coeff
##
## :return: array of placement coeffs [[pos, angle]]
func get_placement_coeffs(phlds: Array, get_last=false) -> Array:
	var coeffs: Array = []
	if phlds:
		var size = phlds[0].get_size() / 2  # get the size of the card (its mesh, actually)
		var n = phlds.size() - 1
		var coeff = FUNC_COEFF  # empirical coefficient to make the cards on the sides lower, then the cards in the middle
		var a = -(n + 1) * size.x / 2  # a in [a, b]
		var b = -a  # b in [a, b]
		var dh = size.y * 2  # delta height
		var phi = PHI  # -15 degrees
		var psi = -phi  # +15 degrees

		var start_ind = n if get_last else 0

		var cur_point: float  # current offset from a
		var cur_rad: float  # current angle in rads
		# when there is only one card
		if not n:
			coeffs.push_back([Vector3(a, 0, _f(a, 1)), phi])
		else:
			for i in range(start_ind, phlds.size()):
				cur_point = a + i * 2 * b / n
				cur_rad = phi + i * 2 * psi / n
				coeffs.push_back([Vector3(cur_point, i * dh, _f(cur_point, n * coeff)), cur_rad])
	return coeffs[0] if get_last else coeffs
