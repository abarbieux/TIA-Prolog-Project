class_name MovementManager
extends Object


var main


func _init(_main) -> void:
	main = _main


func init_movement(value: int, index: int, _carte_movement: bool = true, testpos: Vector2 = Vector2.INF) -> bool:
	if testpos != Vector2.INF:
		move_player(testpos, index, value, _carte_movement)
		return false
	
	var cell: Vector2 = get_available_cell(value)
	
	if cell != Vector2.INF:
		var pos = get_new_pos(cell, value)
		if pos != Vector2.INF:
			move_player(pos, index, value, _carte_movement)
			return false
	
	return true


func get_available_cell(value) -> Vector2:
	var _clamp = clamp(main.player_selected.current_case.x + value, 0, main.clamp_max)
	
	for chemin_chosen in main._A_Star.chemins.size():
		if is_valid_cell(chemin_chosen, _clamp):
			
			var path = get_best_path(chemin_chosen, _clamp)
			if path != [] && path.size() <= abs(value):
			
				if !is_player_on_cell(chemin_chosen, _clamp):
					return Vector2(chemin_chosen, _clamp)
	
	return Vector2.INF


func move_player(new_pos, index, value, carte_movement: bool = true) -> void:
	main.player_selected.current_case = new_pos
	var offset = main.get_child(2).rect_pivot_offset * (Vector2(1, 1) - main.get_child(2).rect_scale)
	main.player_selected.position = (main._path.get_child(
			main.player_selected.current_case.y).curve.get_point_position(
					main.player_selected.current_case.x) * main.get_child(2).rect_scale) + offset
					
	main.add_score(value, main.player_selected.pays)
	
	if carte_movement:
		var cyclist_on_cell : Array = get_players_on_cell(new_pos[1],new_pos[0])
		print(cyclist_on_cell)
		if cyclist_on_cell.size() > 1:
			for cyclist in cyclist_on_cell:
				if cyclist != main.player_selected :
					var remember = main.player_selected
					main.player_selected = cyclist
					move_player(Vector2(new_pos[0],main.shift_position(new_pos[1],new_pos[0])),index,0,false)
					main.player_selected = remember
					break
					
		main._Deck.deck_carte_player[main._country_turn_index].erase(value)
		main._Deck._cards.append(value)
		main._Deck.empty_deck_check()
	
	if main._A_Star.chemins[new_pos[1]][new_pos[0]] == 2:
		question_mark_case(index)
	
	for child in main.UIComponent.current_cards_buttons.get_children():
		child.queue_free()
		
	
	if carte_movement == false:
		return
	
	if main._A_Star.chemins[new_pos.y][new_pos.x] == 3:
		main.is_end = true
		
	if main.turn_already_past == false:
		main.turn_already_past = true
		main.pass_turn()



func get_last_cyclist_movable() -> Array:
	var last = INF
	var chosen_teamates: Array = []
	for teamate in main.countries[main._country_turn_index].members:
		main.player_selected = teamate
		var place : Vector2 = main.player_selected.current_case
		if main.player_selected.fall == false:
			for carte in main._Deck.deck_carte_player[main._country_turn_index]:
				if get_all_path_available(carte, main.player_selected).size() != 0:
					if place.x < last:
						last = place.x
						chosen_teamates = [teamate]
					elif place.x == last:
						chosen_teamates.append(teamate)
					break
	return chosen_teamates


func select_last_cyclist_movable() -> Array:
	var chosen_teamates = get_last_cyclist_movable()
	if chosen_teamates != []:
		return chosen_teamates
	return []


func question_mark_case(index):
	var surprise_movement: int = randi() % 7 - 3
	print_bonus(surprise_movement)
	if surprise_movement == 0:
		return
		
	var occupied_list: Array = []
	
	var _clamp = clamp(main.player_selected.current_case.x + surprise_movement, 0, main.clamp_max)
	for chemin_chosen in main._A_Star.chemins.size():
		if is_valid_cell(chemin_chosen, _clamp):
			if is_player_on_cell(chemin_chosen, _clamp):
				var cycliste = get_player_on_cell(chemin_chosen, _clamp)
				occupied_list.append(cycliste)
			else:
				if !init_movement(surprise_movement, index, false):
					return
	
	occupied_list.append(main.player_selected)
	fall(occupied_list)


func fall(to_fall: Array) -> void:
	var fall_case_x =  to_fall[0].current_case.x
	for cyclist in to_fall :
		cyclist.fall = true
		cyclist.counter_fall = 4
		cyclist.current_case = Vector2(fall_case_x, main._A_Star.chemins.size() - 1)
		
		var offset = main.get_child(2).rect_pivot_offset * (Vector2(1, 1) - main.get_child(2).rect_scale)
		cyclist.position = (main._path.get_child(
			cyclist.current_case.y).curve.get_point_position(
				cyclist.current_case.x) * main.get_child(2).rect_scale) + offset

func get_all_path_available(value, cyclist) -> PoolVector2Array:
	var _clamp = clamp(cyclist.current_case.x + value,0, main.clamp_max)
	for chemin_chosen in main._A_Star.chemins.size():
		var _count : int = 0
		var check_pos_no_occupied : bool = true
		if is_valid_cell(chemin_chosen, _clamp):
			var best_path: PoolVector2Array = main._A_Star._get_path(
					cyclist.current_case, Vector2(_clamp, chemin_chosen))
			
			if best_path.size() == 0 || best_path.size() > value:
				continue
			
			for player in main._players:
				if player.current_case == best_path[-1]: 
					check_pos_no_occupied = false
					break
			
			if check_pos_no_occupied:
				return best_path
		else:
			_count += 1
	return PoolVector2Array()


func is_valid_cell(chemin_chosen, _clamp) -> bool:
	if (
			main._A_Star.chemins[chemin_chosen][_clamp] == 0
			or main._A_Star.chemins[chemin_chosen][_clamp] == 2
			or main._A_Star.chemins[chemin_chosen][_clamp] == 3
	):
		return true
	else:
		return false


func is_player_on_cell(chemin_chosen, _clamp) -> bool:
	for cycliste in main._players:
		if Vector2(_clamp, chemin_chosen) == cycliste.current_case:
			return true
	return false


func get_player_on_cell(chemin_chosen, _clamp):
	for cycliste in main._players:
		if Vector2(_clamp, chemin_chosen) == cycliste.current_case:
			return cycliste

func get_players_on_cell(chemin_chosen, _clamp):
	var cyclist_on_cell : Array = []
	for cycliste in main._players:
		if Vector2(_clamp, chemin_chosen) == cycliste.current_case:
			cyclist_on_cell.append(cycliste)
	return cyclist_on_cell


func get_best_path(chemin_chosen, _clamp):
	var best_path: Array = main._A_Star._get_path(
	main.player_selected.current_case, Vector2(_clamp, chemin_chosen))
	
	return best_path


func get_new_pos(cell, value):
	var path = get_best_path(cell.x, cell.y)
	if path != [] && path.size() <= abs(value):
		var new_pos : Vector2 = path[-1]
	
		return new_pos
	
	return Vector2.INF

func print_bonus(bonus):
	var bonus_log = Button.new()
	var icon_img = Image.new()
	var icon_texture = ImageTexture.new()
	if bonus < 0 :
		icon_img.load("res://Picture/Cards/bonus_neg_" + str(abs(bonus)) + ".png") 
	else:
		icon_img.load("res://Picture/Cards/bonus_" + str(bonus) + ".png")
	icon_texture.create_from_image(icon_img)
	bonus_log.set_button_icon(icon_texture)
	bonus_log.set("expand_icon", true)
	bonus_log.rect_min_size.y = 45
	bonus_log.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var numero_cycliste = str(main.player_selected.numero)
	var pays_cycliste = str(main.player_selected.pays)
	bonus_log.set_text(pays_cycliste + " " + numero_cycliste)
	var bonus_logs = main.UIComponent.bonus_logs
	var child_count = bonus_logs.get_child_count()
	if child_count == 5:
		var child = bonus_logs.get_child(0)
		bonus_logs.remove_child(child)
	bonus_logs.add_child(bonus_log)

#func player_shiftable(best_path) :
#	for player in main._player:
#		if player.current_case == best_path[-1]:
#			pass
