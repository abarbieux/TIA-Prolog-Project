extends Control

onready var _path = $Paths/Path2D

const Countries:Array = ["italie", "hollande", "belgique", "allemagne"]
const NumberOfTeamMember:int = 3

var _Players:Array = []
var _country_turn_index:int = 0 # team who begins
var player_selected:Cycliste
var Deck_list: Array
var cards : Deck
signal Change_turn(Team)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	
	cards = Deck.new()
	cards.MakeDeck()	
#	var rng = randi() % cards._cards.size()
	
	for country in Countries:
		for PlayerNumber in range(1, NumberOfTeamMember + 1):
			_Players.append(CreateNewPlayer(country, PlayerNumber))
	
	for player in _Players :
		player.position = _path.curve.get_point_position(0)
	
	Init_deck()
	Display_deck_button()

func CreateNewPlayer(Pays:String, Numero:int):
	var _player = Cycliste.new()
	_player.Pays = Pays
	_player.numero = Numero
	_player.name = Pays + str(Numero)
	$Player_Container.add_child(_player)
	return _player

# Creat the deck of each participant
func Init_deck() -> void :
	var Deck:int
	while Deck < 4:
		Deck +=1
		var Carte:int
		var Carte_list:Array
		while Carte < 5:
			Carte+=1
			var rng = randi() % cards._cards.size()
			Carte_list.append(cards._cards[rng])
			cards._cards.remove(rng)
		Deck_list.append(Carte_list)

func Display_deck_button() -> void :
	var i = 0
	for carte in Deck_list[_country_turn_index]:
		var button = Button.new()
		button.text = str(carte)
		button.rect_min_size.x = 96
		button.icon = preload("res://icon.png")
		$Bottom.add_child(button)
		var c = button.connect("pressed", self, "_button_pressed", [button, carte, i])
		i += 1
#		add_child(button)

func _button_pressed(button, value, index) -> void :
	choose_player(value, index)

func MovePlayer(value, index):
	player_selected.CurrentCase += value
	player_selected.CurrentCase = clamp(player_selected.CurrentCase, 0, _path.curve.get_point_count() - 1)
	player_selected.position = _path.curve.get_point_position(player_selected.CurrentCase)

	for child in $Bottom.get_children():
		child.queue_free()
	Deck_list[_country_turn_index].erase(value)
	cards._cards.append(value)
	Empty_Deck_check()
	
	_country_turn_index += 1
	if _country_turn_index > Countries.size() - 1:
		_country_turn_index = 0
	emit_signal("Change_turn",Countries[_country_turn_index])
	Display_deck_button()

func refile_deck(Index:int):
	var Carte:int
	var Carte_list:Array
	while Carte < 5:
		Carte+=1
		var rng = randi() % cards._cards.size()
		Carte_list.append(cards._cards[rng])
		cards._cards.remove(rng)
	Deck_list[Index] = Carte_list

func choose_player(value, index):
	for kids in $ChoosePlayer.get_children() :
		kids.queue_free()
	for player in _Players:
		if player.Pays == Countries[_country_turn_index] :
			var button = Button.new()
			button.text = str(player.name)
			button.rect_min_size.x = 96
			button.icon = preload("res://icon.png")
			$ChoosePlayer.add_child(button)
			var c = button.connect("pressed", self, "_button_player_pressed", [player, value, index])
#	return self

signal Player_Chosen
func _button_player_pressed(player, value, index) -> void:
	player_selected = player
	for kids in $ChoosePlayer.get_children() :
		kids.queue_free()
	MovePlayer(value, index)
#	emit_signal("Player_Chosen")
	
func Empty_Deck_check() -> void:
	var i : int = 0
	while i < Deck_list.size():
		if Deck_list[i] == []:
			refile_deck(i)
			
		i += 1
