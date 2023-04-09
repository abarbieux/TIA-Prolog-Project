class_name Deck
extends Object


const NumberOfValue:int = 12
const MaxNumberOfValue:int = 8
var _cards:Array = []
var Deck_Carte_Player: Array


func MakeDeck() -> void:
	randomize()
	 
	for i in range(1, NumberOfValue + 1):
		for j in range(1, MaxNumberOfValue + 1):
			_cards.append(3)
	
	print(_cards)


# Creat the deck of each participant
func Init_deck() -> void :
	var Deck:int
	while Deck < 4:
		Deck +=1
		var Carte:int
		var Carte_list:Array
		while Carte < 5:
			Carte+=1
			var rng = randi() % _cards.size()
			Carte_list.append(_cards[rng])
			_cards.remove(rng)
		Deck_Carte_Player.append(Carte_list)


func refile_deck(Index:int):
	var Carte:int
	var Carte_list:Array
	while Carte < 5:
		Carte+=1
		var rng = randi() % _cards.size()
		Carte_list.append(_cards[rng])
		_cards.remove(rng)
	Deck_Carte_Player[Index] = Carte_list


func Empty_Deck_check() -> void:
	var i : int = 0
	while i < Deck_Carte_Player.size():
		if Deck_Carte_Player[i] == []:
			refile_deck(i)
		
		i += 1
