class_name MovementManager
extends Object


var main


func _init(_main) -> void:
	main = _main


func init_movement(value: int, index: int, _carte_movement: bool = true, testpos:Vector2 = Vector2.INF) -> bool:
	if testpos != Vector2.INF:
		move_player(testpos, index, value, _carte_movement)
		return false
	
	var cell:Vector2 = get_available_cell(value, index)
	
	if cell != Vector2.INF:
		var pos = get_new_pos(cell, value, index)
		if pos != Vector2.INF:
			move_player(pos, index, value, _carte_movement)
			return false
	
	return true


func get_available_cell(value, index) -> Vector2:
	var _clamp = clamp(main.player_selected.CurrentCase.x + value, 0, main.Clamp_Max)
	
	for Chemin_Chosen in main._A_Star.Chemins.size():
		if is_valid_cell(Chemin_Chosen, _clamp):
			
			var path = get_best_path(Chemin_Chosen, _clamp)
			if path != [] && path.size() <= value:
			
				if !is_player_on_cell(Chemin_Chosen, _clamp):
					return Vector2(Chemin_Chosen, _clamp)
	
	return Vector2.INF


func move_player(New_Pos, index, value, Carte_Movment : bool = true) -> void:
	main.player_selected.CurrentCase = New_Pos
	main.player_selected.position = main._path.get_child(
			main.player_selected.CurrentCase.y).curve.get_point_position(
					main.player_selected.CurrentCase.x)
	
	main.Add_Score(value, main.player_selected.Pays)
	
	if main._A_Star.Chemins[New_Pos[1]][New_Pos[0]] == 2:
		question_mark_case(index)
	
	for child in main.UIComponent.current_cards_buttons.get_children():
		child.queue_free()
		
	if Carte_Movment == true :
		main._Deck.Deck_Carte_Player[main._country_turn_index].erase(value)
		main._Deck._cards.append(value)
		main._Deck.Empty_Deck_check()
	else:
		return
	
	if main._A_Star.Chemins[New_Pos.y][New_Pos.x] == 3:
		main.is_end = true
		
	if main.Turn_already_past == false:
		main.Turn_already_past = true
		main.Pass_Turn()


func get_last_cyclist_movable() -> Array:
	var Last = INF
	var chosen_teamates: Array = []
	for Teamate in main.Countries[main._country_turn_index].members:
		main.player_selected = Teamate
		var Place : Vector2 = main.player_selected.CurrentCase
		if main.player_selected.Fall == false:
			for carte in main._Deck.Deck_Carte_Player[main._country_turn_index]:
				if get_all_path_available(carte, main.player_selected).size() != 0:
					if Place.x < Last:
						Last = Place.x
						chosen_teamates = [Teamate]
					elif Place.x == Last:
						chosen_teamates.append(Teamate)
					break
	return chosen_teamates


func select_last_cyclist_movable() -> Array:
	var chosen_teamates = get_last_cyclist_movable()
	if chosen_teamates != []:
		return chosen_teamates
	return []


func question_mark_case(index: int) -> void:
	var surprise_movement: int = randi() % 7 - 3
#	surprise_movement = 2
	if surprise_movement == 0:
		return
	
	var New_pos : Vector2 = main.player_selected.CurrentCase + Vector2(surprise_movement, 0)
	var Occupied_List : Array = []
	
	var _clamp = clamp(main.player_selected.CurrentCase.x + surprise_movement, 0, main.Clamp_Max)
	for Chemin_Chosen in main._A_Star.Chemins.size():
		if is_valid_cell(Chemin_Chosen, _clamp):
			if is_player_on_cell(Chemin_Chosen, _clamp):
				var cycliste = get_player_on_cell(Chemin_Chosen, _clamp)
				Occupied_List.append(cycliste)
			else:
				if !init_movement(surprise_movement, index, false):
					return
	
	Occupied_List.append(main.player_selected)
	fall(Occupied_List)


func fall(To_fall: Array) -> void:
	var fall_case_x =  To_fall[0].CurrentCase.x
	for Cyclist in To_fall :
		Cyclist.Fall = true
		Cyclist.Counter_Fall = 4
		Cyclist.CurrentCase = Vector2(fall_case_x, main._A_Star.Chemins.size()-1)
		Cyclist.position = main._path.get_child(
				Cyclist.CurrentCase.y).curve.get_point_position(Cyclist.CurrentCase.x)


func get_all_path_available(value, cyclist) -> PoolVector2Array:
	var _clamp = clamp(cyclist.CurrentCase.x + value,0, main.Clamp_Max)
	var count : int = 0
	for Chemin_Chosen in main._A_Star.Chemins.size():
		var check_pos_no_occupied : bool = true
		if is_valid_cell(Chemin_Chosen, _clamp):
			var Best_Path: PoolVector2Array = main._A_Star._get_path(
					cyclist.CurrentCase, Vector2(_clamp, Chemin_Chosen))
			
			if Best_Path.size() == 0 || Best_Path.size() > value:
				continue
			
			for player in main._Players:
				if player.CurrentCase == Best_Path[-1] : 
					check_pos_no_occupied = false
					break
			
			if check_pos_no_occupied:
				return Best_Path
		else:
			count += 1
	return PoolVector2Array()


func is_valid_cell(Chemin_Chosen, _clamp) -> bool:
	if (
			main._A_Star.Chemins[Chemin_Chosen][_clamp] == 0
			or main._A_Star.Chemins[Chemin_Chosen][_clamp] == 2
			or main._A_Star.Chemins[Chemin_Chosen][_clamp] == 3
	):
		return true
	else:
		return false


func is_player_on_cell(Chemin_Chosen, _clamp) -> bool:
	for cycliste in main._Players:
		if Vector2(_clamp, Chemin_Chosen) == cycliste.CurrentCase:
			return true
	return false


func get_player_on_cell(Chemin_Chosen, _clamp):
	for cycliste in main._Players:
		if Vector2(_clamp, Chemin_Chosen) == cycliste.CurrentCase:
			return cycliste


func get_best_path(Chemin_Chosen, _clamp):
	var Best_Path:Array = main._A_Star._get_path(
	main.player_selected.CurrentCase, Vector2(_clamp, Chemin_Chosen))
	
	return Best_Path


func get_new_pos(cell, value, index):
	var path = get_best_path(cell.x, cell.y)
	
	if path != [] && path.size() <= value:
		var New_Pos : Vector2 = path[-1]
	
		return New_Pos
	
	return Vector2.INF


#func player_shiftable(Best_Path) :
#	for player in main._Player:
#		if player.CurrentCase == Best_Path[-1] :
#			pass
