extends Node
class_name GameAI

var instance
var _GameWebSocket
var _A_Star


# GameAI constructor
# @param _instance: Game instance (should be a singleton)
func _init(_instance):
	instance = _instance
	_GameWebSocket = instance._GameWebSocket
	_A_Star = instance._A_Star


func _ready():
	pass


# Get the game board
# @return: a string with the game board
func get_game_board():
	return String(_A_Star.chemins)


# Get the players information
# @return: a dictionary with the players information
func get_players_information():
	var buffer = {}
	var i = 0
	for _player in instance._players:
		if not buffer.has(_player.pays):
			buffer[_player.pays] = {}
		buffer[_player.pays][_player.pays + "_" + String((i % 3) + 1)] = _player._to_dict()
		i += 1
	return buffer
		

# Get the teams deck
# @return: a dictionary with the teams deck
func get_teams_deck():
	var buffer = {}
	var i = 0
	var pays = instance.countries
	for _deck in instance._Deck.deck_carte_player:
		buffer[pays[i].name] = _deck
		i += 1
	return buffer
	

# Remove a card from the given deck
# @param deck: the deck to remove the card from
# @param card: the card to remove
# @return: an array with the deck without the card. The original deck is not modified
func remove_card_from_deck(deck, card):
	var buffer = []
	for _card in deck:
		if _card != card:
			buffer.append(_card)
	return buffer


# Get the selected player
# @return: a string with the selected player
func get_selected_player():
	var buffer = {}
	var players_movable = instance._MovementManager.select_last_cyclist_movable()
	if len(players_movable) > 0:
		var selected_player = players_movable[0]
		buffer = "%s_%s" % [selected_player.pays, selected_player.numero]
	return buffer


# Get the game information
# @return: a dictionary with the game information
func get_game_information_dict():
	var buffer = {}
	buffer["game_board"] = get_game_board()
	buffer["player_information"] = get_players_information()
	buffer["teams_deck"] = get_teams_deck()
	buffer["selected_player"] = get_selected_player()
	return buffer
