class_name A_star
extends Node


# 0 = OK, 1 = Hole/Don't exit, 2 = Occuped
var cheminA = [0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,2,0,0,3,3,3,3,3]
var cheminB = [0,0,0,2,0,1,1,1,1,0,1,1,1,1,1,1,0,1,1,0,3,3,3,3,3]
var cheminC = [0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,3,3,3]
var cheminD = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
# ligne jaune
#var cheminA = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
# ligne verte
#var cheminB = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
# ligne bleue
#var cheminC = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,0]
# ligne rouge
#var cheminE = [0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0]
# ligne noire
#var cheminF = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
var chemins = [cheminA, cheminB, cheminC, cheminD]
var used_cells = []
var pos = [0, 0]
var NumOfMove = 3
var path: PoolVector2Array


onready var astar = AStar2D.new()


func _ready() -> void:
	var x = 0
	var y = 0
	for chemin in chemins:
		for value in chemin:
			if value == 0 || value == 2 || value == 3:
				used_cells.append(Vector2(x, y))
			x += 1
		y += 1
		x = 0
	
	_add_points()
	_connect_points()


func _add_points():
	for cell in used_cells:
		astar.add_point(id(cell), cell, 1.0)


func _connect_points():
	for cell in used_cells:
		# Right, Left, Down, Up, TopLeft, TopRight, BottomLeft, BottomRight
#		var neighbors = [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1), Vector2(-1, -1), Vector2(1, -1), Vector2(-1,1), Vector2(1,1)]
		
		# Right, Left, TopLeft, TopRight, BottomLeft, BottomRight
		var neighbors = [Vector2(1,0), Vector2(-1,0), Vector2(-1, -1), Vector2(1, -1), Vector2(-1,1), Vector2(1,1)]
		
		# Right, TopRight, BottomRight
#		var neighbors = [Vector2(1,0), Vector2(1, -1), Vector2(1,1)]
		for neighbor in neighbors:
			var next_cell = cell + neighbor
			if used_cells.has(next_cell):
				astar.connect_points(id(cell), id(next_cell))


func _get_path(start,end):
	if chemins[start.y][start.x] == 1:
		var not_way_available: bool = true
		for chemin in chemins:
			if chemin[start.x] != 1 and not_way_available == true:
				start = Vector2(start.x, chemins.find(chemin))
				not_way_available = false
				
		if not_way_available == true:
			print("There is a problem with your map, you're not supposed to be here.")
			return []
			
	path = astar.get_point_path(id(start), id(end))
	if path.size() != 0:
		path.remove(0)
	#print("Path = ", path)
	return path


func id(point):
	var a = point.x
	var b = point.y
	return (a + b) * (a + b + 1) / 2 + b
