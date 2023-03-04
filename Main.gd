extends Control

onready var _Allemagne = $Allemagne
onready var _path = $Paths/Path2D

var _current_case:int = 0
var Deck_list: Array
var index_process:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	for allemand in _Allemagne :
		allemand.position = _path.curve.get_point_position(_current_case)
	
	Init_deck()
	Init_deck_button()



func _process(delta: float) -> void:
	
	var i : int = 0
	while i < Deck_list.size():
		if Deck_list[i] == []:
			refile_deck(i)
			
		i += 1


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
	var _player = choose_player()
	_current_case += value
	_current_case = clamp(_current_case, 0, _path.curve.get_point_count() - 1)
	_player.position = _path.curve.get_point_position(_current_case)
	button.queue_free()

	Deck_list[0].erase(value)


func refile_deck(Index:int):
	var Carte:int
	var Carte_list:Array
	while Carte < 5:
		Carte+=1
		Carte_list.append(randi()%12 +1)
	Deck_list[Index] = Carte_list
	Init_deck_button()

func choose_player():
	for allemand in _Allemagne:
		var button = Button.new()
		button.text = str(allemand)
		button.rect_min_size.x = 96
		button.icon = preload("res://icon.png")
		$ChoosePlayer.add_child(button)
		var c = button.connect("pressed", self, "_button_player_pressed", [allemand])
		
func _button_player_pressed(allemand) -> void :
	var player = str(allemand)
	for kids in allemand.get_parent() :
		kids.queue_free()
	
