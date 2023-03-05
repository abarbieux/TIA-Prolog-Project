extends Control

onready var _path = $Paths/A

const Countries:Array = ["italie", "hollande", "belgique", "allemagne"]
const NumberOfTeamMember:int = 3

var _Players:Array = []
var _country_turn_index:int = 0 # team who begins
var player_selected:Cycliste

var CheminA = [true,true,true,true,true,true,true,true]
var CheminB = [true,true,false,false,true,true,true,true]
var CheminC = [true,true,true,true,true,true,true,true]
var CheminD = [true,true]

var Chemins = [CheminA,CheminB,CheminC]



var _Deck : Deck
signal Change_turn(Team)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	
	var nextindex:Array = []
	var myChemin = 2
	var myIndex = 2
	var NumOfMove = 4
	for n in range(1, NumOfMove + 1):
		for i in range(myChemin - 1, myChemin + 2): 
			if i == -1 || i > 2:
				continue
			if myIndex > Chemins[i].size() - 1:
				continue
			
			if Chemins[i][myIndex+n] == true:
				nextindex.append([i, myIndex+n])
	print(nextindex)
	
	_Deck = Deck.new()
	_Deck.MakeDeck()	

	
	for country in Countries:
		for PlayerNumber in range(1, NumberOfTeamMember + 1):
			_Players.append(CreateNewPlayer(country, PlayerNumber))
	
	for player in _Players :
		player.position = _path.curve.get_point_position(0)
	
	_Deck.Init_deck()
	Display_deck_button()

func CreateNewPlayer(Pays:String, Numero:int):
	var _player = Cycliste.new()
	_player.Pays = Pays
	_player.numero = Numero
	_player.name = Pays + str(Numero)
	$Player_Container.add_child(_player)
	return _player



func Display_deck_button() -> void :
	var i = 0
	for carte in _Deck.Deck_Carte_Player[_country_turn_index]:
		var button = Button.new()
		button.text = str(carte)
		button.rect_min_size.x = 96
		button.icon = preload("res://icon.png")
		$Current_Cards.add_child(button)
		var c = button.connect("pressed", self, "_button_pressed", [button, carte, i])
		i += 1
#		add_child(button)

func _button_pressed(button, value, index) -> void :
	choose_player(value, index)

func MovePlayer(value, index):
	player_selected.CurrentCase += value
	player_selected.CurrentCase = clamp(player_selected.CurrentCase, 0, _path.curve.get_point_count() - 1)
	player_selected.position = _path.curve.get_point_position(player_selected.CurrentCase)

	for child in $Current_Cards.get_children():
		child.queue_free()
	_Deck.Deck_Carte_Player[_country_turn_index].erase(value)
	_Deck._cards.append(value)
	_Deck.Empty_Deck_check()
	
	_country_turn_index += 1
	if _country_turn_index > Countries.size() - 1:
		_country_turn_index = 0
	emit_signal("Change_turn",Countries[_country_turn_index])
	Display_deck_button()



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
	

