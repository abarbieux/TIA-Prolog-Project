extends Node
class_name A_star

# 0 = OK, 1 = Hole/Don't exit, 2 = Occuped
var CheminA = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ]
var CheminB = [0,0,0,0,0,1,1,1,1,0,1,1,1,1,1,1,0,1,1,0,0,0,0,0,0 ]
var CheminC = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ]

# ligne jaune
#var CheminA = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
# ligne verte
#var CheminB = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
# ligne bleue
#var CheminC = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,0]
# ligne rouge
#var CheminE = [0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0]
# ligne noire
#var CheminF = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
# photoshop : retirer les 2 flèches qui tournent, fusionner les cases doubles
var Chemins = [CheminA, CheminB, CheminC]
var used_cells = []

var pos = [0, 0]
var NumOfMove = 3

onready var astar = AStar2D.new()
var path : PoolVector2Array

func _ready() -> void:
	var x = 0
	var y = 0
	for chemin in Chemins:
		for n in chemin:
			if n == 0 || n == 2:
				used_cells.append(Vector2(x, y))
			x += 1
		y += 1
		x = 0
	
	_add_points()
	_connect_points()
	
	_get_path(Vector2(1,1), Vector2(2,0))
	
	print(path)

func _add_points():
	for cell in used_cells:
		astar.add_point(id(cell), cell, 1.0)

func _connect_points():
	for cell in used_cells:
		# Right, Left, Down, Up, TopLeft, TopRight, BottomLeft, BottomRight
#		var neighbors = [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1), Vector2(-1, -1), Vector2(1, -1), Vector2(-1,1), Vector2(1,1)]
		
		# Right, TopRight, BottomRight
		var neighbors = [Vector2(1,0), Vector2(1, -1), Vector2(1,1)]
		for neighbor in neighbors:
			var next_cell = cell + neighbor
			if used_cells.has(next_cell):
				astar.connect_points(id(cell), id(next_cell), false)

func _get_path(start,end):
	path = astar.get_point_path(id(start), id(end))
	if path.size() != 0:
		path.remove(0)
	return path

func id(point):
	var a = point.x
	var b = point.y
	return (a + b) * (a + b + 1) / 2 + b
