extends Node
class_name ChatBotAI

var instance
var heuristic_mode: int


## Class Constructor.
## Injecting the main instance to this object to ensure data liability.
## Heuristic mode goes from 0 to 2 and follow thoses specifications:
##	0: Plays the biggest card possible every turn to make the last players go as far as possible.
##	1: Plays the chances cases as much as possible to spare the maximum of high cards.
##	2: Combine both 0 and 1 heuristics to improve the chances for the team to go the fartest.
##		In this heuristic, the card chosen will take into account the maximum bid from the chances cases,
##		in our actual implementation it has 57% chances to be a positive outcome.
##		In a minmax situation, that means that we can take into account that positive outcome so that
##		we can play towards those cases by adding the maximum value to our case picking card.
##		i.e: deck = [2,3,5] ==> chance case at 3, so the maximum mouvement would be 3 + 3 and so 6.
##			So, the player plays the card "3" instead of "5" because it is the best chance to get a
##			"6" without using the said card (which in this case he doesn't have) and to save the "5"
##			which would be lower than "6". Doing so, we can have a positive outcome of our move at 57%
##			chance and thus saving our high card for later to go further into the game faster.
##	3: Same as the heuristic 2, but takes into account the possibility to block other players path
##		by looking at which cards they have and if it's possible to make them pass their turn with
##		one of our movements cards.
func _init(_instance):
	instance = _instance
	heuristic_mode = 1
	
	
func get_best_card(team: String) -> int:
	match heuristic_mode:
		0: return get_best_card_h0(team)
		1: return get_best_card_h1(team)
		_: return get_best_card_h0(team)
	

func get_best_card_h0(team: String) -> int:
	var country_index = get_country_index_from_team(team)
	var team_deck = instance._Deck.deck_carte_player[country_index]
	var value = team_deck.max()
	var duplicated_deck : Array = team_deck.duplicate(true)
	var player_selected = instance._MovementManager.select_last_cyclist_movable()
	while true:
		if instance._MovementManager.get_all_path_available(value, player_selected[0]).size() > 0:
			return value
		if len(duplicated_deck) == 0:
			break
		duplicated_deck.erase(value)
		value = duplicated_deck.max()
		
	return -1
		
	
func get_best_card_h1(team: String) -> int:
	var country_index = get_country_index_from_team(team)
	var team_deck = instance._Deck.deck_carte_player[country_index]
	var player_selected: Cycliste = instance._MovementManager.select_last_cyclist_movable()[0]
	var cyclist_number: int = player_selected.numero
	var first_chance_case_distance: int = team_deck.min()
	while true:
		var test_old = first_chance_case_distance
		first_chance_case_distance = find_first_chance_case_distance(team, cyclist_number, first_chance_case_distance + 1)
		print("First chance case possible for %s n°%s is %s cases away." % [team, cyclist_number, first_chance_case_distance])
		if test_old == first_chance_case_distance:
			print("Error... %s" % test_old)
			break
			
		if first_chance_case_distance == -1:
			return get_best_card_h0(team)
			
		var sum_to_chance_case: Array = find_sum_of(team, first_chance_case_distance)
		sum_to_chance_case.sort()
		if len(sum_to_chance_case) != 0:
			print("sum_to_chance_case : ", sum_to_chance_case)
			for card in sum_to_chance_case:
				if instance._MovementManager.get_all_path_available(card, player_selected).size() > 0:
					print("Playing sum card: ", card)
					return card
		print("No sum found for %s" % first_chance_case_distance)
	return -1
		

## Get the given cyclist position in a @Vector2 format.
## @parameter team: The team to get the cyclist from.
## @parameter cyclist_number: The number of the cyslist to get the position from.
## @return the position of the cyclist or a @Vector2 filled with -1.0 if cyclist doesn't exists.
func get_cyclist_position(team, cyclist_number) -> Vector2:
	if team == null or cyclist_number == null: return Vector2(-1.0, -1.0)
	var found_cyclist: Cycliste
	for cyclist in instance._players:
		if cyclist.pays == team and cyclist.numero == int(cyclist_number):
			found_cyclist = cyclist
			break
	if found_cyclist == null:
		return Vector2(-1.0, -1.0)
	else:
		return found_cyclist.current_case
		
		
## Find the array of cards from the given team deck that makes the sum of a number.
## @parameter team: The team to calculate the cards sum from.
## @parameter number: The number that the sum has to match.
## @return an array with the cards to make the given sum or an empty one if not found.
func find_sum_of(team: String, number: int) -> Array:
	var country_index = get_country_index_from_team(team)
	var team_deck: Array = instance._Deck.deck_carte_player[country_index]
	print("Team Deck:", team_deck)
	for card_1 in team_deck:
		if card_1 > number:
			continue
		elif card_1 == number:
			return [card_1]
		
		var removed_card_deck = team_deck.duplicate(true)
		removed_card_deck.erase(card_1)
		print("Removed Deck:", removed_card_deck)
		if number - card_1 in removed_card_deck:
			print("#90 Sum for %s %s" % [number, [card_1, number - card_1]])
			return [card_1, number - card_1]
		
		var accumulator = card_1;
		var cards = [card_1]
		for i in range(len(removed_card_deck)):
			if accumulator >= number:
				break
			if accumulator + removed_card_deck[i] <= number:
				accumulator += removed_card_deck[i]
				cards.append(removed_card_deck[i])
		if accumulator == number:
			print("#101 Sum for %s %s" % [number, cards])
			return cards #.sort()
	return []


## Find the first chance case distance from the given cyclist.
## @parameter case_skipping: Amount of cases to skip before looking for the first chance case.
##							 This parameter should always be set to the minimum card value a player has in his deck.
## @return the distance between the player and the first chance case found.
func find_first_chance_case_distance(team: String, cyclist_number: int, case_skipping: int = 0) -> int:
	var country_index = get_country_index_from_team(team)
	var team_deck: Array = instance._Deck.deck_carte_player[country_index]
	var cyclist_position: Vector2 = get_cyclist_position(team, cyclist_number)
	var chances_cases = get_all_chances_cases()
	var chance_case_position = Vector2(-1.0, -1.0)
	
	for chance_case in chances_cases:
		if (
			cyclist_position.x + case_skipping <= chance_case.x and (chance_case.x <= chance_case_position.x or chance_case_position.x == -1.0)
		):
			chance_case_position = chance_case
	if chance_case_position != Vector2(-1.0, -1.0):
		var distance = distance(cyclist_position, chance_case_position)
		return distance if distance <= sum_array(team_deck) else -1
	return -1


## Find all the chances cases in the map.
## @return the chances cases in the map inside an @Array.
func get_all_chances_cases() -> Array:
	var result: Array = []
	var paths: Array = instance._A_Star.chemins
	for row in range(len(paths)):
		for column in range(len(paths[row])):
			if paths[row][column] == 2:
				result.append(Vector2(float(column), float(row)))
	return result
	

## Calculate the distance between two @Vector2.
## @parameter position1: First position.
## @parameter position2: Second position.
## @return the distance between the two positions.
func distance(position1: Vector2, position2: Vector2) -> int:
	#return int(round(pow((pow(position2[0] - position1[0], 2.0) + pow(position2[1] - position1[1], 2.0)), 0.5)))
	print("Position 1: %s, Position 2: %s" % [String(position1), String(position2)])
	return int(position2.x - position1.x)
	
	
func get_country_index_from_team(team: String) -> int:
	var country_index: int = 0
	for country in instance.countries:
		if country.name == team: break
		country_index += 1
	return country_index
	
	
func sum_array(array: Array):
	var result = 0
	for i in array:
		result += i
	return result
