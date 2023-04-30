class_name Deck
extends Object


const number_of_value: int = 12
const max_number_of_value: int = 8
var _cards: Array = []
var deck_carte_player: Array


func make_deck() -> void:
	for i in range(1, number_of_value + 1):
		for _j in range(max_number_of_value):
			_cards.append(i)


# Creat the deck of each participant
func init_deck() -> void:
	var deck: int = 0
	while deck < 4:
		deck += 1
		var carte: int = 0
		var carte_list: Array = []
		while carte < 5:
			carte += 1
			var rng = randi() % _cards.size()
			carte_list.append(_cards[rng])
			_cards.remove(rng)
		deck_carte_player.append(carte_list)


func refile_deck(Index: int):
	var carte: int = 0
	var carte_list: Array = []
	while carte < 5:
		carte += 1
		var rng = randi() % _cards.size()
		carte_list.append(_cards[rng])
		_cards.remove(rng)
	deck_carte_player[Index] = carte_list


func empty_deck_check() -> void:
	var i: int = 0
	while i < deck_carte_player.size():
		if deck_carte_player[i] == []:
			refile_deck(i)
		i += 1
