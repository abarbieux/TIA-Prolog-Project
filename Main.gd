extends Node2D

onready var _player = $Player
onready var _path = $Paths/Path2D

var _current_case:int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	_player.position = _path.curve.get_point_position(_current_case)


func _on_Button_pressed() -> void:
	_current_case += randi() % 6 + 1
	_current_case = clamp(_current_case, 0, _path.curve.get_point_count() - 1)
	_player.position = _path.curve.get_point_position(_current_case)
