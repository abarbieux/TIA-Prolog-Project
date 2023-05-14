class_name Main
extends Control



#signal change_turn(team)

const number_of_team_member: int = 3
# Change to true to visualize a random party.
const is_unit_test_mode := false

var countries: Array = [Country.new("italie"),
		Country.new("hollande"),
		Country.new("belgique"),
		Country.new("allemagne")]
var _players: Array = []
var _country_turn_index: int = 0 # team who begins
var player_selected: Cycliste
var _A_Star := A_star.new()
var _GameWebSocket := GameWebSocket.new(self)
var _ChatBotAI := ChatBotAI.new(self)
var _GameAI := GameAI.new(self)
var _MovementManager := MovementManager.new(self)
var _Deck: Deck
var turn_already_past: bool = false
var clamp_max: int
var score_belgique: int = 0
var score_allemagne: int = 0
var score_hollande: int = 0
var score_italie: int = 0
var is_end := false
var is_definitely_the_end := false
var is_selecting_case := false

onready var _path = $Map/Paths
onready var panel = $Panel
onready var UIComponent := $UIComponent
onready var ErrorComponent := $ErrorComponent



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	add_child(_A_Star)
	add_child(_GameWebSocket)
	add_child(_ChatBotAI)
	add_child(_GameAI)
	panel._GameWebSocket = _GameWebSocket
	_GameWebSocket.panel = panel
	
	_Deck = Deck.new()
	_Deck.make_deck()
	
	clamp_max = _A_Star.cheminA.size()-1
	
	for country in countries:
		for player_number in range(1, number_of_team_member + 1):
			var _player = create_new_player(country.name, player_number)
			_players.append(_player)
			if _player.pays == "italie" : 
				_player.position = Vector2(896,438)
			elif _player.pays == "hollande" : 
				_player.position = Vector2(876,438)
			elif _player.pays == "belgique" : 
				_player.position = Vector2(916,438)
			else:
				_player.position = Vector2(936,438)
			
			country.members.append(_player)
	
	
	create_button()
	
	_Deck.init_deck()
	UIComponent.display_deck_button(_Deck.deck_carte_player[_country_turn_index])
	update_team_carte_display()
	

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		var _server_pid = OS.execute("taskkill", ["/im", "swipl.exe", "/F"], false)


func create_button():
	var x = 0
	var y = 0
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0.5,0.5,0.5,1)
	for path in _path.get_child_count() - 1:
		path = _path.get_child(path) as Path2D
		for point in path.curve.get_point_count():
			if x != 0:
				var button = TextureButton.new()
				button.rect_position = path.curve.get_point_position(point)
				button.visible = false
				button.set_normal_texture(load("res://Picture/Cards/select_case.png") )
				button.set_pressed_texture(load("res://Picture/Cards/select_case_mouse.png"))
	#			button.add_stylebox_override("normal", StyleBoxEmpty.new())
	#			button.add_stylebox_override("hover", stylebox)
				button.expand = true
				button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT
				
				button.rect_min_size = Vector2(50,50)
				button.rect_position -= button.rect_min_size / 2
#				button.disabled
				button.editor_description = str(x) + "," + str(y)
				button.connect("pressed", self, "set_selected_cell_pos", [x, y])
				path.add_child(button)
			x += 1
		y += 1
		x = 0


signal cell_pos_changed
var selected_cell_pos:Vector2

func set_selected_cell_pos(posX, posY):
	selected_cell_pos = Vector2(posX, posY)
	emit_signal("cell_pos_changed")


func hide_all_cell_button():
	for path in _path.get_children():
		for btn in path.get_children():
			btn.visible = false
	is_selecting_case = false


func create_new_player(pays: String, numero: int):
	var _player = Cycliste.new()
	_player.pays = pays
	_player.numero = numero
	_player.name = pays + str(numero)
	$Player_Container.add_child(_player)
	return _player


func init_pre_select_move_phase():
	if is_definitely_the_end:
		return
	
	if is_unit_test_mode || countries[_country_turn_index].Tactic != 0:
		yield(get_tree().create_timer(0.1), "timeout")
	
	
	UIComponent.current_team.change_text(countries[_country_turn_index].name)
	var possible = check_all_possibles_path()
	
	if !possible:
		if !is_unit_test_mode && countries[_country_turn_index].Tactic == 0:
			ErrorComponent.pass_tour.show()
			yield(ErrorComponent.pass_tour, "confirmed")
		pass_turn()
	else:
		if is_unit_test_mode:
			play_virtual_game()
		elif countries[_country_turn_index].Tactic != 0:
			var possible_cyclist: Array = _MovementManager.select_last_cyclist_movable()
			
			_ChatBotAI.heuristic_mode = countries[_country_turn_index].Tactic
			
			var chosen_card = _ChatBotAI.get_best_card(countries[_country_turn_index].name)
			
			
			turn_already_past = false
			_button_player_pressed(possible_cyclist[0],chosen_card, 0)
			


func play_virtual_game():
	var num_of_cards = _Deck.deck_carte_player[_country_turn_index]
	var randomnly_selected_card = randi() % num_of_cards.size()
	
	var possible_cyclist: Array = _MovementManager.select_last_cyclist_movable()
	var randomnly_selected_cyclist = randi() % possible_cyclist.size()
	
	turn_already_past = false
	_button_player_pressed(possible_cyclist[randomnly_selected_cyclist],
			num_of_cards[randomnly_selected_card], 0)
	
	


func check_all_possibles_path() -> bool:
	for player in countries[_country_turn_index].members:
		if player.counter_fall == 0:
			for carte in _Deck.deck_carte_player[_country_turn_index]:
				if _MovementManager.get_all_path_available(carte, player).size() != 0:
					return true
	
	return false


func _button_pressed(_button, value, index) -> void :
	hide_all_cell_button()
	UIComponent.choose_player(value, index, _MovementManager.select_last_cyclist_movable())


func _button_player_pressed(player, value, index) -> void:
	
	player_selected = player
	
	for child in UIComponent.choose_player_panel.get_children():
		child.queue_free()
	
	var cells = get_all_cell_available(value, player)
	
	if cells.size() != 0:
		for path in _path.get_children():
			for btn in path.get_children():
				for cell in cells:
					if btn.editor_description == str(cell.x) + "," + str(cell.y):
						btn.visible = true
	else:
		ErrorComponent.movement_error.show()
#	for card in UIComponent.current_cards_buttons.get_children():
#		card.queue_free()
	
	is_selecting_case = true
	if !is_unit_test_mode && countries[_country_turn_index].Tactic == 0:
		yield(self, "cell_pos_changed")
		
		
		
		
	if is_selecting_case:
		
		if is_unit_test_mode || countries[_country_turn_index].Tactic != 0:
			
			
			var check_card_chance = check_card_chance(value)
			var error
			print("countries[_country_turn_index].Tactic : ", countries[_country_turn_index].Tactic)
			
			if check_card_chance != Vector2.ZERO:
				
				error = _MovementManager.init_movement(value, index, true, check_card_chance)
			
			elif countries[_country_turn_index].Tactic == 3:
				
				pass
				
			else:
				player_selected = _MovementManager.select_last_cyclist_movable()[0]
				print("player_selected : ", player_selected)
				error = _MovementManager.init_movement(value, index, true)
				
			is_selecting_case = false
			if error:
				init_pre_select_move_phase()
				
		else:

			var error = _MovementManager.init_movement(value, index, true, selected_cell_pos)
			is_selecting_case = false
			if error:
				ErrorComponent.movement_error.show()
	
	
	hide_all_cell_button()

func check_card_chance(value):
	var possible_cyclist: Array = _MovementManager.select_last_cyclist_movable()
#	print("possible_cyclist : ", possible_cyclist)
	for cyclist in possible_cyclist:
		var x_position = cyclist.current_case.x + value
		
		for path in _A_Star.chemins.size():
			
			var check_chance = _A_Star.chemins[path][x_position]
			
			if check_chance == 2:
				if check_choiced_case_available(x_position, path, cyclist, value).size() != 0:
					player_selected = cyclist
#					print("player_selected : ", player_selected)
#					print("vector : ", Vector2(x_position, path))
					return Vector2(x_position, path)
	print("no chance")
	return Vector2.ZERO

func check_choiced_case_available(path_x: int, chemin_chosen: int, cyclist, value: int):
	

	var check_pos_no_occupied : bool = true
	if _MovementManager.is_valid_cell(chemin_chosen, path_x):
		var best_path: PoolVector2Array = _A_Star._get_path(
				cyclist.current_case, Vector2(path_x, chemin_chosen))
		
		if best_path.size() == 0 || best_path.size() > value:
			return PoolVector2Array()
		
		for player in _players:
			if player.current_case == best_path[-1]: 
				if shift_position(player.current_case.y, player.current_case.x) == -1:
					check_pos_no_occupied = false
					break
			
		if check_pos_no_occupied:
			return best_path
			
	return PoolVector2Array()

func get_all_cell_available(value, cyclist) -> PoolVector2Array:
	var _clamp = clamp(cyclist.current_case.x + value,0, clamp_max)
	var cells:PoolVector2Array = []
	for chemin_chosen in _A_Star.chemins.size():
		if _MovementManager.is_valid_cell(chemin_chosen, _clamp):
			if _A_Star._get_path(
				cyclist.current_case, Vector2(cyclist.current_case.x + value, chemin_chosen)):
				if !_MovementManager.is_player_on_cell(chemin_chosen, _clamp):
					cells.append(Vector2(_clamp, chemin_chosen))
				elif shift_position(chemin_chosen, _clamp) != -1 :
					cells.append(Vector2(_clamp, chemin_chosen))
				
	return cells


func shift_position_externe(pos_y:int, pos_x:int):
	if pos_y+1 <= _A_Star.chemins.size():
		if _MovementManager.is_valid_cell(pos_y+1,pos_x):
			if !_MovementManager.is_player_on_cell(pos_y+1, pos_x):
				return pos_y+1
			else:
				return shift_position_externe(pos_y+1, pos_x)
	return -1
	

func shift_position_interne(pos_y:int, pos_x:int):
	if pos_y-1 >= 0:
		if _MovementManager.is_valid_cell(pos_y-1,pos_x):
			if !_MovementManager.is_player_on_cell(pos_y-1, pos_x):
				return pos_y-1
			else:
				return shift_position_interne(pos_y-1, pos_x)
	return -1
	

func shift_position(pos_y:int, pos_x:int):
	var externe : int = shift_position_externe(pos_y, pos_x)
	var interne:int = shift_position_interne(pos_y, pos_x)
	if externe != -1:
		return externe
	elif interne != -1:
		return interne
	return -1



func _on_Send_pressed() -> void:
	panel._on_Send_pressed()


func pass_turn():
	for child in UIComponent.current_cards_buttons.get_children():
		child.queue_free()
	
	for player in _players:
		if player.counter_fall != 0:
			player.counter_fall -= 1
			if player.counter_fall == 0:
				player.fall = false

			print("player.counter_fall", player.counter_fall, player)
	
	_country_turn_index += 1
	if _country_turn_index > countries.size() - 1:
		_country_turn_index = 0
		init_check_if_end_phase()
	
	UIComponent.display_deck_button(_Deck.deck_carte_player[_country_turn_index])
	update_team_carte_display()
	init_pre_select_move_phase()


func init_check_if_end_phase():
	if is_end:
		end()


func end():
	ErrorComponent.end.show()
	var scores = str("PARTIE FINIE \n\nScore Belgique : ", score_belgique, "\nScore Allemagne : ", score_allemagne, "\nScore Hollande : ", score_hollande, "\nScore Italie : ", score_italie)
	$ErrorComponent/end/AnimationPlayer.play("popup")
	$ErrorComponent/end.dialog_text = scores
	is_definitely_the_end = true


func add_score(value: int, team: String):
	var key = "score_" + team.to_lower()
	if key in self:
		self.set(key, self.get(key) + value)
#		print(key + " += value | ", self.get(key))
	else:
		print("WTF ARE YOU DOING")
		
func update_team_carte_display():
	for team in 4:
		UIComponent.display_team_deck(_Deck.deck_carte_player[team],team)
