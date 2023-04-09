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
	var _clamp = clamp(main.player_selected.CurrentCase.x + value,0, main.Clamp_Max)
	
	for Chemin_Chosen in main._A_Star.Chemins.size():
		if (
				main._A_Star.Chemins[Chemin_Chosen][_clamp] == 0
				or main._A_Star.Chemins[Chemin_Chosen][_clamp] == 2
				or main._A_Star.Chemins[Chemin_Chosen][_clamp] == 3
		):
			var Check_player_already_here = false
			for cycliste in main._Players:
				if Vector2(_clamp, Chemin_Chosen) == cycliste.CurrentCase :
					Check_player_already_here = true
			
			if !Check_player_already_here:
				var Best_Path:Array = main._A_Star._get_path(
						main.player_selected.CurrentCase, Vector2(_clamp, Chemin_Chosen))
				if Best_Path != [] && Best_Path.size() <= value:
					var New_Pos : Vector2 = Best_Path[-1]
					print("_country_turn_index : ", main._country_turn_index)
					MovePlayer(New_Pos, index,value)
					return true
	
	return false


func MovePlayer(New_Pos, index, value, Carte_Movment : bool = true):
	main.player_selected.CurrentCase = New_Pos
	main.player_selected.position = main._path.get_child(
			main.player_selected.CurrentCase.y).curve.get_point_position(
					main.player_selected.CurrentCase.x)
	
	main.Add_Score(value, main.player_selected.Pays)
	
	if main._A_Star.Chemins[New_Pos[1]][New_Pos[0]] == 2 :
		Question_Mark_Case(index,value)
	
	for child in main.UIComponent.current_cards_buttons.get_children():
		child.queue_free()
		
	if Carte_Movment == true :
		main._Deck.Deck_Carte_Player[main._country_turn_index].erase(value)
		main._Deck._cards.append(value)
		main._Deck.Empty_Deck_check()
	else:
		return
	
	if main._A_Star.Chemins[New_Pos.y][New_Pos.x] == 3 :
		main.is_end = true
		
	else :
		if main.Turn_already_past == false:
			main.Turn_already_past = true
			main.Pass_Turn()


func get_last_cyclist_movable(Team):
	var Team_list : Array
	for cycliste in main._Players:
		if cycliste.Pays == Team:
			Team_list.append(cycliste)
	var Last  = INF
	var chosen_teamates: Array = []
	for Teamate in Team_list:
		main.player_selected = Teamate
		var Place : Vector2 = main.player_selected.CurrentCase
		if main.player_selected.Fall == false :
			if Place.x < Last :
				for carte in main._Deck.Deck_Carte_Player[main._country_turn_index]:
					if Get_All_Path_Available(carte, main.player_selected).size() != 0:
						Last = Place.x
						chosen_teamates = [Teamate]
						break
			elif Place.x == Last :
				for carte in main._Deck.Deck_Carte_Player[main._country_turn_index]:
					if Get_All_Path_Available(carte, main.player_selected).size() != 0:
						chosen_teamates.append(Teamate)
						break
	return chosen_teamates


func select_last_cyclist_movable(Team):
	var chosen_teamates = get_last_cyclist_movable(Team.name)
	if chosen_teamates != []:
		return chosen_teamates
	return []


func Question_Mark_Case(index,value) :
	var surprise_movment: int = randi() % 7 - 3
	print("surprise_movment",surprise_movment)
	surprise_movment = 0
	if surprise_movment == 0 :
		return
		
	var New_pos : Vector2 = main.player_selected.CurrentCase + Vector2(surprise_movment,0)
	var Occupied_List : Array = []
	
	var _clamp = clamp(main.player_selected.CurrentCase.x + surprise_movment,0, main.Clamp_Max)
	for Chemin_Chosen in main._A_Star.Chemins.size():
		if (
				main._A_Star.Chemins[Chemin_Chosen][_clamp] == 0
				or main._A_Star.Chemins[Chemin_Chosen][_clamp] == 2
				or main._A_Star.Chemins[Chemin_Chosen][_clamp] == 3
		):
			var Check_player_already_here = false
			for cycliste in main._Players:
				if Vector2(_clamp, Chemin_Chosen) == cycliste.CurrentCase :
					Check_player_already_here = true
					Occupied_List.append(cycliste)

			if !Check_player_already_here:
				print("CurrentCase : ", main.player_selected.CurrentCase)
				print("NextCase : ", Vector2(_clamp, Chemin_Chosen))
				var Best_Path:Array = main._A_Star._get_path(main.player_selected.CurrentCase, Vector2(_clamp, Chemin_Chosen))
				if Best_Path != [] && Best_Path.size() <= surprise_movment:
					var New_Pos : Vector2 = Best_Path[-1]
					print("New Pos : ", New_Pos)
					MovePlayer(New_Pos, index,surprise_movment, false)
					return
		
	Occupied_List.append(main.player_selected)
	fall(Occupied_List)


func fall(To_fall : Array):
	print("fall")
	var fall_case_x =  To_fall[0].CurrentCase.x
	for Cyclist in To_fall :
		Cyclist.Fall = true
		Cyclist.Counter_Fall = 4
		Cyclist.CurrentCase = Vector2(fall_case_x, main._A_Star.Chemins.size()-1)
		Cyclist.position = main._path.get_child(
				Cyclist.CurrentCase.y).curve.get_point_position(Cyclist.CurrentCase.x)


func Get_All_Path_Available(value, cyclist):
	var _clamp = clamp(cyclist.CurrentCase.x + value,0, main.Clamp_Max)
	var count : int = 0
	for Chemin_Chosen in main._A_Star.Chemins.size():
		var check_pos_no_occupied : bool = true
		if (
					main._A_Star.Chemins[Chemin_Chosen][_clamp] == 0
					or main._A_Star.Chemins[Chemin_Chosen][_clamp] == 2
					or main._A_Star.Chemins[Chemin_Chosen][_clamp] == 3
			):
			var Best_Path: PoolVector2Array = main._A_Star._get_path(
					cyclist.CurrentCase, Vector2(_clamp, Chemin_Chosen))
			
			if Best_Path.size() == 0 || Best_Path.size() > value:
				continue
			
			for player in main._Players:
				if player.CurrentCase == Best_Path[-1] : 
					check_pos_no_occupied = false
					break
			if check_pos_no_occupied:
				print("Best_Path",Best_Path)
				return Best_Path
		else:
			count += 1
	return []


#func player_shiftable(Best_Path) :
#	for player in main._Player:
#		if player.CurrentCase == Best_Path[-1] :
#			pass
