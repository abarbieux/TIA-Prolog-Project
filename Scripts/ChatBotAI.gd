extends Node
class_name ChatBotAI

var instance


# Class Constructor
# Injecting the main instance to this object to ensure data liability
func _init(_instance):
	instance = _instance
	
	
func get_best_card(team, player):
	var country_index = instance.Countries.find(team, 0)
	var team_deck = instance._Deck.Deck_Carte_Player[country_index]
	# Heuristic (Naive)
	#	• Play the highest card possible
	return team_deck.max()
	
	
func get_cyclist_position(team, cyclist_number) -> Vector2:
	var team_list : Array
	var found_cyclist : Cycliste
	for cyclist in instance._Players:
		if cyclist.Pays == team and cyclist.numero == int(cyclist_number):
			found_cyclist = cyclist
			break
	if found_cyclist == null:
		return Vector2(-1.0, -1.0)
	else:
		return found_cyclist.CurrentCase
