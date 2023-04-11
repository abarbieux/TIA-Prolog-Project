class_name Main
extends Control


signal change_turn(team)


const number_of_team_member: int = 3


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
var _MovementManager := MovementManager.new(self)
var _Deck: Deck
var turn_already_past: bool = false
var clamp_max: int
var score_belgique: int = 0
var score_allemagne: int = 0
var score_hollande: int = 0
var score_italie: int = 0
var is_end := false


onready var _path = $Paths
onready var panel = $Panel
onready var UIComponent := $UIComponent
onready var ErrorComponent := $ErrorComponent


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	add_child(_A_Star)
	add_child(_GameWebSocket)
	add_child(_ChatBotAI)
	panel._GameWebSocket = _GameWebSocket
	_GameWebSocket.panel = panel
	
	_Deck = Deck.new()
	_Deck.make_deck()
	
	clamp_max = _A_Star.cheminA.size()-1
	
	for country in countries:
		for player_number in range(1, number_of_team_member + 1):
			var _player = create_new_player(country.name, player_number)
			_players.append(_player)
			country.members.append(_player)
	
	_Deck.init_deck()
	UIComponent.display_deck_button(_Deck.deck_carte_player[_country_turn_index])
	
	init_pre_select_move_phase()


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		OS.execute("taskkill", ["/im", "swipl.exe", "/F"], false)


func create_new_player(pays: String, numero: int):
	var _player = Cycliste.new()
	_player.pays = pays
	_player.numero = numero
	_player.name = pays + str(numero)
	$Player_Container.add_child(_player)
	return _player


func init_pre_select_move_phase():
	UIComponent.current_team.change_text(countries[_country_turn_index].name)
	var possible = check_all_possibles_path()
	
	if !possible:
		ErrorComponent.pass_tour.show()
		yield(ErrorComponent.pass_tour, "confirmed")
		pass_turn()


func check_all_possibles_path() -> bool:
	for player in countries[_country_turn_index].members:
		for carte in _Deck.deck_carte_player[_country_turn_index]:
			if _MovementManager.get_all_path_available(carte, player).size() != 0:
				return true
	
	return false


func _button_pressed(button, value, index) -> void:
	UIComponent.choose_player(value, index, _MovementManager.select_last_cyclist_movable(countries[_country_turn_index]))


func _button_player_pressed(player, value, index) -> void:
	player_selected = player
	
	for child in UIComponent.choose_player_panel.get_children():
		child.queue_free()
	
	var error = _MovementManager.init_movement(value, index)
	
	if error:
		ErrorComponent.movement_error.show()


func _on_Send_pressed() -> void:
	panel._on_Send_pressed()


func pass_turn():
	for child in UIComponent.current_cards_buttons.get_children():
		child.queue_free()
	
	for player in _players:
		if player.counter_fall != 0:
			player.counter_fall -= 1
			if player.counter_fall == 0:
				player.Fall = false

			print("player.counter_fall", player.counter_fall, player)
	
	_country_turn_index += 1
	if _country_turn_index > countries.size() - 1:
		_country_turn_index = 0
		init_check_if_end_phase()
		
	emit_signal("change_turn", countries[_country_turn_index].name)
	UIComponent.display_deck_button(_Deck.deck_carte_player[_country_turn_index])
	init_pre_select_move_phase()


func init_check_if_end_phase():
	if is_end:
		end()


func end():
	ErrorComponent.end.show()
	print("end")
	print("score_belgique += value", score_belgique)
	print("score_allemagne", score_allemagne)
	print("score_hollande", score_hollande)
	print("score_italie", score_italie)


func add_score(value: int, team: String):
	var key = "score_" + team.to_lower()
	if key in self:
		self.set(key, self.get(key) + value)
		print(key + " += value | ", self.get(key))
	else:
		print("WTF ARE YOU DOING")
		
