class_name Main
extends Control


signal Change_turn(Team)


const NumberOfTeamMember:int = 3


var Countries:Array = [Country.new("italie"),
		Country.new("hollande"),
		Country.new("belgique"),
		Country.new("allemagne")]
var _Players:Array = []
var _country_turn_index:int = 0 # team who begins
var player_selected:Cycliste
var _A_Star := A_star.new()
var _GameWebSocket := GameWebSocket.new(self)
var _ChatBotAI := ChatBotAI.new(self)
var _MovementManager := MovementManager.new(self)
var _Deck: Deck
var Turn_already_past: bool = false
var Clamp_Max: int
var Score_belgique: int = 0
var Score_allemagne: int = 0
var Score_hollande: int = 0
var Score_italie: int = 0
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
	_Deck.MakeDeck()
	
	Clamp_Max = _A_Star.CheminA.size()-1
	
	for country in Countries:
		for PlayerNumber in range(1, NumberOfTeamMember + 1):
			var _player = create_new_player(country.name, PlayerNumber)
			_Players.append(_player)
			country.members.append(_player)
	
	_Deck.Init_deck()
	UIComponent.Display_deck_button(_Deck.Deck_Carte_Player[_country_turn_index])
	
	init_pre_select_move_phase()


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		OS.execute("taskkill", ["/im", "swipl.exe", "/F"], false)


func create_new_player(Pays:String, Numero:int):
	var _player = Cycliste.new()
	_player.Pays = Pays
	_player.numero = Numero
	_player.name = Pays + str(Numero)
	$Player_Container.add_child(_player)
	return _player


func init_pre_select_move_phase():
	UIComponent.current_team.change_text(Countries[_country_turn_index].name)
	var possible = check_all_possibles_path()
	
	if !possible:
		ErrorComponent.pass_tour.show()
		yield(ErrorComponent.pass_tour, "confirmed")
		Pass_Turn()


func check_all_possibles_path() -> bool:
	for player in Countries[_country_turn_index].members:
		for carte in _Deck.Deck_Carte_Player[_country_turn_index]:
			if _MovementManager.Get_All_Path_Available(carte, player).size() != 0:
				return true
	
	return false


func _button_pressed(button, value, index) -> void :
	UIComponent.choose_player(value, index, _MovementManager.select_last_cyclist_movable(Countries[_country_turn_index]))


func _button_player_pressed(player, value, index) -> void:
	player_selected = player
	
	for child in UIComponent.choose_player_panel.get_children():
		child.queue_free()
	
	var error = _MovementManager.init_movement(value, index)
	
	if error:
		ErrorComponent.movement_error.show()


func _on_Send_pressed() -> void:
	panel._on_Send_pressed()


func Pass_Turn():
	for child in UIComponent.current_cards_buttons.get_children():
		child.queue_free()
	
	for player in _Players:
		if player.Counter_Fall != 0:
			player.Counter_Fall -= 1
			if  player.Counter_Fall == 0 :
				player.Fall = false
			
			
			print("player.Counter_Fall",player.Counter_Fall,player)
	
	_country_turn_index += 1
	if _country_turn_index > Countries.size() - 1:
		_country_turn_index = 0
		init_check_if_end_phase()
		
	emit_signal("Change_turn",Countries[_country_turn_index].name)
	UIComponent.Display_deck_button(_Deck.Deck_Carte_Player[_country_turn_index])
	init_pre_select_move_phase()


func init_check_if_end_phase():
	if is_end:
		End()


func End():
	ErrorComponent.end.show()
	print("end")
	print("Score_belgique += value",Score_belgique)
	print("Score_allemagne",Score_allemagne)
	print("Score_hollande",Score_hollande)
	print("Score_italie",Score_italie)


func Add_Score(value : int, Team : String) :
	var key = "Score_" + Team.to_lower()
	if key in self:
		self.set(key, self.get(key) + value)
		print(key + " += value | ", self.get(key))
	else:
		print("WTF ARE YOU DOING")
