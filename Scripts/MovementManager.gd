class_name MovementManager
extends Object


var main


func _init(_main) -> void:
	main = _main


func init_movement(value: int, index: int) -> bool:
	if is_select_move_possible(value, index):
		pass
	return false


func is_select_move_possible(value, index) -> bool:
	var _clamp = clamp(main.player_selected.current_case.x + value, 0, main.clamp_max)
	
	for chemin_chosen in main._A_Star.chemins.size():
		if (
				main._A_Star.chemins[chemin_chosen][_clamp] == 0
				or main._A_Star.chemins[chemin_chosen][_clamp] == 2
				or main._A_Star.chemins[chemin_chosen][_clamp] == 3
		):
			var check_player_already_here = false
			for cycliste in main._players:
				if Vector2(_clamp, chemin_chosen) == cycliste.current_case:
					check_player_already_here = true
			
			if !check_player_already_here:
				var best_path: Array = main._A_Star._get_path(
						main.player_selected.current_case, Vector2(_clamp, chemin_chosen))
				if best_path != [] && best_path.size() <= value:
					var new_pos: Vector2 = best_path[-1]
					print("_country_turn_index: ", main._country_turn_index)
					move_player(new_pos, index, value)
					return true
	
	return false


func move_player(new_pos, index, value, carte_movement: bool = true):
	main.player_selected.current_case = new_pos
	main.player_selected.position = main._path.get_child(
			main.player_selected.current_case.y).curve.get_point_position(
					main.player_selected.current_case.x)
	
	main.add_score(value, main.player_selected.pays)
	
	if main._A_Star.chemins[new_pos[1]][new_pos[0]] == 2:
		question_mark_case(index,value)
	
	for child in main.UIComponent.current_cards_buttons.get_children():
		child.queue_free()
		
	if carte_movement == true:
		main._Deck.deck_carte_player[main._country_turn_index].erase(value)
		main._Deck._cards.append(value)
		main._Deck.empty_deck_check()
	else:
		return
	
	if main._A_Star.chemins[new_pos.y][new_pos.x] == 3:
		main.is_end = true
		
	else:
		if main.turn_already_past == false:
			main.turn_already_past = true
			main.pass_turn()


func get_last_cyclist_movable(team: String):
	var team_list: Array
	for cycliste in main._players:
		if cycliste.pays == team:
			team_list.append(cycliste)
	var last = INF
	var chosen_teamates: Array = []
	for teamate in team_list:
		main.player_selected = teamate
		var place: Vector2 = main.player_selected.current_case
		if main.player_selected.fall == false:
			if place.x < last:
				for carte in main._Deck.deck_carte_player[main._country_turn_index]:
					if get_all_path_available(carte, main.player_selected).size() != 0:
						last = place.x
						chosen_teamates = [teamate]
						break
			elif place.x == last:
				for carte in main._Deck.deck_carte_player[main._country_turn_index]:
					if get_all_path_available(carte, main.player_selected).size() != 0:
						chosen_teamates.append(teamate)
						break
	return chosen_teamates


func select_last_cyclist_movable(team):
	var chosen_teamates = get_last_cyclist_movable(team.name)
	if chosen_teamates != []:
		return chosen_teamates
	return []


func question_mark_case(index, value):
	var surprise_movement: int = randi() % 7 - 3
	print("surprise_movement ", surprise_movement)
	surprise_movement = 0
	if surprise_movement == 0:
		return
		
	var new_pos: Vector2 = main.player_selected.current_case + Vector2(surprise_movement, 0)
	var occupied_list: Array = []
	
	var _clamp = clamp(main.player_selected.current_case.x + surprise_movement, 0, main.clamp_max)
	for chemin_chosen in main._A_Star.chemins.size():
		if (
				main._A_Star.chemins[chemin_chosen][_clamp] == 0
				or main._A_Star.chemins[chemin_chosen][_clamp] == 2
				or main._A_Star.chemins[chemin_chosen][_clamp] == 3
		):
			var check_player_already_here = false
			for cycliste in main._players:
				if Vector2(_clamp, chemin_chosen) == cycliste.current_case:
					check_player_already_here = true
					occupied_list.append(cycliste)

			if !check_player_already_here:
				print("Current Case: ", main.player_selected.current_case)
				print("Next Case: ", Vector2(_clamp, chemin_chosen))
				var best_path: Array = main._A_Star._get_path(main.player_selected.current_case,
															Vector2(_clamp, chemin_chosen))
				if best_path != [] && best_path.size() <= surprise_movement:
					new_pos = best_path[-1]
					print("New Pos: ", new_pos)
					move_player(new_pos, index,surprise_movement, false)
					return
		
	occupied_list.append(main.player_selected)
	fall(occupied_list)


func fall(to_fall: Array):
	print("fall")
	var fall_case_x: float =  to_fall[0].current_case.x
	for cyclist in to_fall:
		cyclist.Fall = true
		cyclist.Counter_Fall = 4
		cyclist.current_case = Vector2(fall_case_x, main._A_Star.chemins.size() - 1)
		cyclist.position = main._path.get_child(cyclist.current_case.y) \
									.curve.get_point_position(cyclist.current_case.x)


func get_all_path_available(value, cyclist):
	var _clamp: float = clamp(cyclist.current_case.x + value, 0, main.clamp_max)
	var count: int = 0
	for chemin_chosen in main._A_Star.chemins.size():
		var check_pos_no_occupied: bool = true
		if (
					main._A_Star.chemins[chemin_chosen][_clamp] == 0
					or main._A_Star.chemins[chemin_chosen][_clamp] == 2
					or main._A_Star.chemins[chemin_chosen][_clamp] == 3
			):
			var best_path: PoolVector2Array = main._A_Star._get_path(cyclist.current_case, Vector2(_clamp, chemin_chosen))
			
			if best_path.size() == 0 || best_path.size() > value:
				continue
			
			for player in main._players:
				if player.current_case == best_path[-1]: 
					check_pos_no_occupied = false
					break
			if check_pos_no_occupied:
				#print("best_path", best_path)
				return best_path
		else:
			count += 1
	return []


#func player_shiftable(best_path):
#	for player in main._Player:
#		if player.CurrentCase == best_path[-1]:
#			pass
