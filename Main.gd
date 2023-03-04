extends Control

onready var _player = $Allemagne1
onready var _path = $Paths/Path2D

var _current_case:int = 0
var Deck_list: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	_player.position = _path.curve.get_point_position(_current_case)
	
	Init_deck()
	Init_deck_button()





# Creat the deck of each participant
func Init_deck() -> void :
	var Deck:int
	while Deck < 4:
		Deck +=1
		var Carte:int
		var Carte_list:Array
		while Carte < 5:
			Carte+=1
			Carte_list.append(randi()%12 +1)
		Deck_list.append(Carte_list)

func Init_deck_button() -> void :
	var i = 0
	for carte in Deck_list[0]:
		var button = Button.new()
		button.text = str(carte)
		button.rect_min_size.x = 96
		button.icon = preload("res://icon.png")
		$Bottom.add_child(button)
		var c = button.connect("pressed", self, "_button_pressed", [button, carte, i])
		i += 1
#		add_child(button)

func _button_pressed(button, value, index) -> void :
	_current_case += value
	_current_case = clamp(_current_case, 0, _path.curve.get_point_count() - 1)
	_player.position = _path.curve.get_point_position(_current_case)
	button.queue_free()
	var Index:int = Find_Index(value)
	Deck_list.remove(Index)
	
func Find_Index(carte:int):
	for pos in Deck_list[0] :
		if Deck_list[0][pos] == carte :
			return pos
	return null



