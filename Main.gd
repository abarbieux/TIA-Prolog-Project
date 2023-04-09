extends Control
class_name Main

onready var _path = $Paths

onready var panel = $Panel

const Countries:Array = ["italie", "hollande", "belgique", "allemagne"]
const NumberOfTeamMember:int = 3

var _Players:Array = []
var _country_turn_index:int = 0 # team who begins
var player_selected:Cycliste

var _A_Star : A_star = preload("res://Scripts/AStar.gd").new()
var _GameWebSocket : GameWebSocket = preload("res://Scripts/GameWebSocket.gd").new(self)
var _ChatBotAI : ChatBotAI = preload("res://Scripts/ChatBotAI.gd").new(self)

var _Deck : Deck
signal Change_turn(Team)
var Turn_already_past : bool = false
var Clamp_Max

var Score_belgique : int = 0
var Score_allemagne : int = 0
var Score_hollande: int = 0
var Score_italie : int = 0

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
			_Players.append(CreateNewPlayer(country, PlayerNumber))	
#	for player in _Players :
#		player.position = _path.get_child(0).curve.get_point_position(0)	
	_Deck.Init_deck()
	Display_deck_button()

func CreateNewPlayer(Pays:String, Numero:int):
	var _player = Cycliste.new()
	_player.Pays = Pays
	_player.numero = Numero
	_player.name = Pays + str(Numero)
	$Player_Container.add_child(_player)
	return _player



func Display_deck_button() -> void :
	var i = 0
	for carte in _Deck.Deck_Carte_Player[_country_turn_index]:
		var button = Button.new()
		button.text = str(carte)
		button.rect_min_size.x = 96
		button.icon = preload("res://icon.png")
		$Current_Cards.add_child(button)
		var c = button.connect("pressed", self, "_button_pressed", [button, carte, i])
		i += 1
#		add_child(button)

func _button_pressed(button, value, index) -> void :
	choose_player(value, index)

func MovePlayer(New_Pos, index, value, Carte_Movment : bool = true):
	player_selected.CurrentCase = New_Pos

	player_selected.position = _path.get_child(player_selected.CurrentCase.y).curve.get_point_position(player_selected.CurrentCase.x)
	
	Add_Score(value,player_selected.Pays)
	
	if _A_Star.Chemins[New_Pos[1]][New_Pos[0]] == 2 :
		Question_Mark_Case(index,value)
	
	for child in $Current_Cards.get_children():
		child.queue_free()
		
	if Carte_Movment == true :
		_Deck.Deck_Carte_Player[_country_turn_index].erase(value)
		_Deck._cards.append(value)
		_Deck.Empty_Deck_check()
	else:
		return
	
	if _A_Star.Chemins[New_Pos.y][New_Pos.x] == 3 :
		End()
		
	else :
		if Turn_already_past == false:
			Turn_already_past = true
			Pass_Turn()
		Display_deck_button()



func choose_player(value, index):
	Turn_already_past = false
	for kids in $ChoosePlayer.get_children() :
		kids.queue_free()
	var cyclistes_movable : Array = select_last_cyclist_movable(Countries[_country_turn_index])
	for cycliste in cyclistes_movable :
		var button = Button.new()
		button.text = str(cycliste.name)
		button.rect_min_size.x = 96
		button.icon = preload("res://icon.png")
		$ChoosePlayer.add_child(button)
		var c = button.connect("pressed", self, "_button_player_pressed", [cycliste, value, index])
		
#	for player in _Players:
#		if player.Pays == Countries[_country_turn_index] :
#			var button = Button.new()
#			button.text = str(player.name)
#			button.rect_min_size.x = 96
#			button.icon = preload("res://icon.png")
#			$ChoosePlayer.add_child(button)
#			var c = button.connect("pressed", self, "_button_player_pressed", [player, value, index])

func get_last_cyclist_movable(Team):
	var Team_list : Array
	for cycliste in _Players:
		if cycliste.Pays == Team:
			Team_list.append(cycliste)
	var Last  = INF
	var chosen_teamates: Array = []
	for Teamate in Team_list:
		player_selected = Teamate
		var Place : Vector2 = player_selected.CurrentCase
		if player_selected.Fall == false :
			if Place.x < Last :
				for carte in _Deck.Deck_Carte_Player[_country_turn_index]:
					if Get_All_Path_Available(carte).size() != 0:
						Last = Place.x
						chosen_teamates = [Teamate]
						break
			elif Place.x == Last :
				for carte in _Deck.Deck_Carte_Player[_country_turn_index]:
					if Get_All_Path_Available(carte).size() != 0:
						chosen_teamates.append(Teamate)
						break
	return chosen_teamates

func select_last_cyclist_movable(Team):
	var chosen_teamates = get_last_cyclist_movable(Team)
	if chosen_teamates != []:
		return chosen_teamates
	$PassTour.show()
	
	for child in $Current_Cards.get_children():
		child.queue_free()
	Pass_Turn()
	
	Display_deck_button()
	return []
	

signal Player_Chosen
func _button_player_pressed(player, value, index) -> void:
	player_selected = player
	for kids in $ChoosePlayer.get_children() :
		kids.queue_free()
		
	var _clamp = clamp(player_selected.CurrentCase.x + value,0, Clamp_Max)
	
	for Chemin_Chosen in _A_Star.Chemins.size():
		if _A_Star.Chemins[Chemin_Chosen][_clamp] == 0 || _A_Star.Chemins[Chemin_Chosen][_clamp] == 2 || _A_Star.Chemins[Chemin_Chosen][_clamp] == 3:
			var Check_player_already_here = false
			for cycliste in _Players:
				if Vector2(_clamp, Chemin_Chosen) == cycliste.CurrentCase :
					Check_player_already_here = true
			
			if !Check_player_already_here:
				var Best_Path:Array = _A_Star._get_path(player_selected.CurrentCase, Vector2(_clamp, Chemin_Chosen))
				if Best_Path != [] && Best_Path.size() <= value:
					var New_Pos : Vector2 = Best_Path[-1]
					print("_country_turn_index : ", _country_turn_index)
					MovePlayer(New_Pos, index,value)
					return
	$Movement_Error.show()
#	emit_signal("Player_Chosen")


		
func Question_Mark_Case(index,value) :
	var surprise_movment: int = randi() % 7 - 3
	print("surprise_movment",surprise_movment)
	surprise_movment = 3
	if surprise_movment == 0 :
		return
		
	var New_pos : Vector2 = player_selected.CurrentCase + Vector2(surprise_movment,0)
	var Occupied_List : Array = []
	
	var _clamp = clamp(player_selected.CurrentCase.x + surprise_movment,0, Clamp_Max)
	for Chemin_Chosen in _A_Star.Chemins.size():
		if _A_Star.Chemins[Chemin_Chosen][_clamp] == 0 || _A_Star.Chemins[Chemin_Chosen][_clamp] == 2 || _A_Star.Chemins[Chemin_Chosen][_clamp] == 3:
			var Check_player_already_here = false
			for cycliste in _Players:
				if Vector2(_clamp, Chemin_Chosen) == cycliste.CurrentCase :
					Check_player_already_here = true
					Occupied_List.append(cycliste)

			if !Check_player_already_here:
				print("CurrentCase : ", player_selected.CurrentCase)
				print("NextCase : ", Vector2(_clamp, Chemin_Chosen))
				var Best_Path:Array = _A_Star._get_path(player_selected.CurrentCase, Vector2(_clamp, Chemin_Chosen))
				if Best_Path != [] && Best_Path.size() <= surprise_movment:
					var New_Pos : Vector2 = Best_Path[-1]
					print("New Pos : ", New_Pos)
					MovePlayer(New_Pos, index,surprise_movment, false)
					return
#				else :
#					var New_Pos := Vector2(_clamp, Chemin_Chosen)
#					MovePlayer(New_Pos, index,surprise_movment, false)
#					return
#			else :
#				print("deja la" , player_selected, player_selected.CurrentCase)
		
	Occupied_List.append(player_selected)
	fall(Occupied_List)

#	var _clamp = clamp(player_selected.CurrentCase.x + value,0, Clamp_Max)
#	for Chemin_Chosen in _A_Star.Chemins.size():
#		if _A_Star.Chemins[Chemin_Chosen][_clamp] == 0 || _A_Star.Chemins[Chemin_Chosen][_clamp] == 2:
#			var Best_Path:Array = _A_Star._get_path(player_selected.CurrentCase, Vector2(_clamp, Chemin_Chosen))
#			var New_Pos : Vector2 = Best_Path[-1]
	# attention le chemin retourner peut etre vide -> prendre en compte le cas du crash
	
	
#	check_neighbor(New_pos)
#	player_selected.CurrentCase = New_pos
#	player_selected.position = _path.get_child(player_selected.CurrentCase.y).curve.get_point_position(player_selected.CurrentCase.x)
#	print("player.CurrentCase",player_selected.CurrentCase)
#	print("player_selected.position ", _path.get_child(player_selected.CurrentCase.y).curve.get_point_position(player_selected.CurrentCase.x))
	
	
func fall(To_fall : Array):
	print("fall")
	var fall_case_x =  To_fall[0].CurrentCase.x
	for Cyclist in To_fall :
		Cyclist.Fall = true
		Cyclist.Counter_Fall = 4
		Cyclist.CurrentCase = Vector2(fall_case_x,_A_Star.Chemins.size()-1)
		Cyclist.position = _path.get_child(Cyclist.CurrentCase.y).curve.get_point_position(Cyclist.CurrentCase.x)
	
#func check_neighbor(New_pos):
#	for player in _Players :
#		if player.CurrentCase == New_pos :
#			print("player.CurrentCase == New_pos", _A_Star.Chemins[New_pos[1]][New_pos[0]+1])
#			if _A_Star.Chemins[New_pos[1]][New_pos[0]+1] == 1:
#				print("fall")
#				fall(_Players) #juste pour eviter l'erreur à changer
#				return
#			else :
#				check_neighbor(Vector2(New_pos[0], New_pos[1]+1))
#				print("new-pos",New_pos)
#				print("new-pos2",Vector2(New_pos[0], New_pos[1]+1))
#				player.CurrentCase = Vector2(New_pos[0], New_pos[1]+1)
#				player.position = _path.get_child(player.CurrentCase.y).curve.get_point_position(player.CurrentCase.x)
#				print("player.CurrentCase",player.CurrentCase)
#				print("player_selected.position ", _path.get_child(player.CurrentCase.y).curve.get_point_position(player.CurrentCase.x))
#				break
func Get_All_Path_Available(value):
	var _clamp = clamp(player_selected.CurrentCase.x + value,0, Clamp_Max)
#	Check_Clamp(_clamp)
	for Chemin_Chosen in _A_Star.Chemins.size():
		var check_pos_no_occupied : bool = true
		if _A_Star.Chemins[Chemin_Chosen][_clamp] == 0 || _A_Star.Chemins[Chemin_Chosen][_clamp] == 2 || _A_Star.Chemins[Chemin_Chosen][_clamp] == 3:
			var Best_Path: PoolVector2Array = _A_Star._get_path(player_selected.CurrentCase, Vector2(_clamp, Chemin_Chosen))
			if Best_Path.size() == 0 || Best_Path.size() > value:
				continue
			for player in _Players:
				if player.CurrentCase == Best_Path[-1] : 
					check_pos_no_occupied = false
					break
			if check_pos_no_occupied :
				print("Best_Path",Best_Path)
				return Best_Path
	return []


func _on_Send_pressed() -> void:
	panel._on_Send_pressed()


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		OS.execute("taskkill", ["/im", "swipl.exe", "/F"], false)

func Pass_Turn():
	for player in _Players:
		if player.Counter_Fall != 0:
			player.Counter_Fall -= 1
			if  player.Counter_Fall == 0 :
				player.Fall = false
			
			
			print("player.Counter_Fall",player.Counter_Fall,player)
	
	_country_turn_index += 1
	if _country_turn_index > Countries.size() - 1:
		_country_turn_index = 0
	emit_signal("Change_turn",Countries[_country_turn_index])
	
	
	
	
func End():
	$end.show()
	print("end")
	print("Score_belgique += value",Score_belgique)
	print("Score_allemagne",Score_allemagne)
	print("Score_hollande",Score_hollande)
	print("Score_italie",Score_italie)
#func Check_Clamp(_clamp) :
#	if _clamp == Clamp_Max :
#		print("_clamp == Clamp_Max")
#		var limit_find : int = 0
#		var index = 0
#		for chemin in _A_Star.Chemins.slice(0,-1) :
#			index += 1 
#			print(index)
##			print("Vector2(_A_Star.Chemins.find(chemin),chemin[Clamp_Max])",Vector2(_A_Star.Chemins.find(chemin),chemin[Clamp_Max]))
#			for player in _Players:
#				if player.CurrentCase == Vector2(_A_Star.Chemins.find(chemin),Clamp_Max):
#					print("limit_find += 1")
#					limit_find += 1
#		if limit_find == _A_Star.Chemins.size() - 2 :
#			print("final")
#			Clamp_Max -= 1
func Add_Score(value : int, Team : String) :
	if Team == "belgique" :
		Score_belgique += value
		print("Score_belgique += value",Score_belgique)
	elif Team == "allemagne" :
		Score_allemagne += value
		print("Score_allemagne += value",Score_allemagne)
	elif Team == "italie" :
		Score_italie += value
		print("Score_italie += value",Score_italie)
	elif Team == "hollande" :
		Score_hollande += value
		print("Score_hollande += value",Score_hollande)
	else :
		print("WTF ARE YOU DOING")
		
