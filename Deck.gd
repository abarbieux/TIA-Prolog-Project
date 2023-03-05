extends Object
class_name Deck

var _cards:Array = []
const NumberOfValue:int = 12
const MaxNumberOfValue:int = 8

func MakeDeck() -> void:
	randomize()
	 
	for i in range(1, NumberOfValue + 1):
		for j in range(1, MaxNumberOfValue + 1):
			_cards.append(i)
	
	print(_cards)


