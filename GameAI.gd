extends Node
class_name GameAI

var instance
var _GameWebSocket
var _A_Star


func _init(_instance):
	instance = _instance
	_GameWebSocket = instance._GameWebSocket
	_A_Star = instance._A_Star

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func get_game_board():
	return String(_A_Star.chemins)


func get_players_information():
	var buffer = {}
	var i = 0
	for _player in instance._players:
		buffer[_player.pays + "_" + String((i % 3) + 1)] = _player._to_dict()
		i += 1
	return buffer
		

func get_teams_deck():
	var buffer = {}
	var i = 0
	var pays = instance.countries
	for _deck in instance._Deck.deck_carte_player:
		buffer[pays[i].name] = _deck
		i += 1
	return buffer


func get_game_information_dict():
	var buffer = {}
	buffer["game_board"] = get_game_board()
	buffer["player_information"] = get_players_information()
	buffer["teams_deck"] = get_teams_deck()
	return buffer
