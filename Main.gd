extends Control

onready var _path = $Paths

const Countries:Array = ["italie", "hollande", "belgique", "allemagne"]
const NumberOfTeamMember:int = 3

var _Players:Array = []
var _country_turn_index:int = 0 # team who begins
var player_selected:Cycliste

var _A_Star : A_star = preload("res://AStar.gd").new()





var _Deck : Deck
signal Change_turn(Team)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	add_child(_A_Star)
	
	_Deck = Deck.new()
	_Deck.MakeDeck()	

	
	for country in Countries:
		for PlayerNumber in range(1, NumberOfTeamMember + 1):
			_Players.append(CreateNewPlayer(country, PlayerNumber))
	
	for player in _Players :
		player.position = _path.get_child(0).curve.get_point_position(0)
	
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

func MovePlayer(New_Pos, index, value):
	player_selected.CurrentCase = New_Pos
	

	player_selected.position = _path.get_child(player_selected.CurrentCase.y).curve.get_point_position(player_selected.CurrentCase.x)

	for child in $Current_Cards.get_children():
		child.queue_free()
	_Deck.Deck_Carte_Player[_country_turn_index].erase(value)
	_Deck._cards.append(value)
	_Deck.Empty_Deck_check()
	
	_country_turn_index += 1
	if _country_turn_index > Countries.size() - 1:
		_country_turn_index = 0
	emit_signal("Change_turn",Countries[_country_turn_index])
	Display_deck_button()



func choose_player(value, index):
	for kids in $ChoosePlayer.get_children() :
		kids.queue_free()
	for player in _Players:
		if player.Pays == Countries[_country_turn_index] :
			var button = Button.new()
			button.text = str(player.name)
			button.rect_min_size.x = 96
			button.icon = preload("res://icon.png")
			$ChoosePlayer.add_child(button)
			var c = button.connect("pressed", self, "_button_player_pressed", [player, value, index])
#	return self

signal Player_Chosen
func _button_player_pressed(player, value, index) -> void:
	player_selected = player
	for kids in $ChoosePlayer.get_children() :
		kids.queue_free()
	var _clamp = clamp(player_selected.CurrentCase.x + value,0, _A_Star.CheminA.size()-1)
	for Chemin_Chosen in _A_Star.Chemins.size():
		print("chemin_chosen",Chemin_Chosen)
		if _A_Star.Chemins[Chemin_Chosen][_clamp] == 0:
			var Check_player_already_here = false
			for cycliste in _Players:
				if Vector2(_clamp, Chemin_Chosen) == cycliste.CurrentCase :
					Check_player_already_here = true
			
			if !Check_player_already_here:
				var Best_Path:Array = _A_Star._get_path(player_selected.CurrentCase, Vector2(_clamp, Chemin_Chosen))
				if Best_Path != []:
					var New_Pos : Vector2 = Best_Path[-1]
					MovePlayer(New_Pos, index,value)
					return
	$Movement_Error.show()
#	emit_signal("Player_Chosen")

