extends Node

class_name ShapeAutoload

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#tetrominoes
static var i_0 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)]
static var i_90 := [Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)]
static var i_180 := [ Vector2i(3, 2), Vector2i(2, 2), Vector2i(1, 2), Vector2i(0, 2), ]
static var i_270 := [ Vector2i(1, 3), Vector2i(1, 2), Vector2i(1, 1), Vector2i(1, 0), ]
static var i := [i_0, i_90, i_180, i_270]

static var t_0 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
static var t_90 := [Vector2i(2, 1),Vector2i(1, 0), Vector2i(1, 1),  Vector2i(1, 2)]
static var t_180 := [Vector2i(1, 2), Vector2i(2, 1), Vector2i(1, 1), Vector2i(0, 1), ]
static var t_270 := [Vector2i(0, 1),Vector2i(1, 2), Vector2i(1, 1), Vector2i(1, 0),  ]
static var t := [t_0, t_90, t_180, t_270]

static var o_0 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
static var o_90 := [Vector2i(1, 0),  Vector2i(1, 1), Vector2i(0, 0), Vector2i(0, 1)]
static var o_180 := [Vector2i(1, 1),   Vector2i(0, 1),Vector2i(1, 0), Vector2i(0, 0)]
static var o_270 := [Vector2i(0, 1), Vector2i(0, 0), Vector2i(1, 1), Vector2i(1, 0)]
static var o := [o_0, o_90, o_180, o_270]

static var z_0 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)]
static var z_90 := [Vector2i(2, 0), Vector2i(2, 1),Vector2i(1, 1),  Vector2i(1, 2)]
static var z_180 := [Vector2i(2, 2), Vector2i(1, 2), Vector2i(1, 1), Vector2i(0, 1)]
static var z_270 := [ Vector2i(0, 2), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 0),]
static var z := [z_0, z_90, z_180, z_270]

static var s_0 := [Vector2i(2, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
static var s_90 := [Vector2i(2, 2), Vector2i(2, 1), Vector2i(1, 0), Vector2i(1, 1), ]
static var s_180 := [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 1), Vector2i(1, 1),  ]
static var s_270 := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 2), Vector2i(1, 1), ]
static var s := [s_0, s_90, s_180, s_270]

static var l_0 := [Vector2i(1, 1), Vector2i(0, 1),  Vector2i(2, 1), Vector2i(2, 0), ]
static var l_90 := [Vector2i(1, 1), Vector2i(1, 0), Vector2i(1, 2), Vector2i(2, 2)]
static var l_180 := [Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 1), Vector2i(0, 2), ]
static var l_270 := [Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 0),  Vector2i(0, 0),]
static var l := [l_0, l_90, l_180, l_270]

static var j_0 := [Vector2i(0, 1), Vector2i(0, 0), Vector2i(1, 1), Vector2i(2, 1)]
static var j_90 := [Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)]
static var j_180 := [ Vector2i(2, 1), Vector2i(2, 2), Vector2i(1, 1), Vector2i(0, 1), ]
static var j_270 := [Vector2i(1, 2), Vector2i(0, 2), Vector2i(1, 1), Vector2i(1, 0), ]
static var j := [j_0, j_90, j_180, j_270]

static var shapes := [i, t, o, z, s, l, j]

enum Shape {I, T, O, Z, S, L, J, NULL}

static func get_shapes(desired_shape: Shape):
	if desired_shape == Shape.I:
		return i
	if desired_shape == Shape.O:
		return o
	if desired_shape == Shape.T:
		return t
	if desired_shape == Shape.Z:
		return z
	if desired_shape == Shape.S:
		return s
	if desired_shape == Shape.L:
		return l
	if desired_shape == Shape.J:
		return j
	return Shape.NULL
	
	

static func determine_shape(query_shape) -> Shape:
#	query_shape.sort()
	for maybe_i in i:
#		maybe_i.sort()
		if query_shape == maybe_i:
			return Shape.I
	for maybe_i in t:
#		maybe_i.sort()
		if query_shape == maybe_i:
			return Shape.T
	for maybe_i in o:
#		maybe_i.sort()
		if query_shape == maybe_i:
			return Shape.O
	for maybe_i in z:
#		maybe_i.sort()
		if query_shape == maybe_i:
			return Shape.Z
	for maybe_i in s:
#		maybe_i.sort()
		if query_shape == maybe_i:
			return Shape.S	
	for maybe_i in l:
#		maybe_i.sort()
		if query_shape == maybe_i:
			return Shape.L	
	for maybe_i in j:
#		maybe_i.sort()
		if query_shape == maybe_i:
			return Shape.J
	return Shape.NULL	
	
