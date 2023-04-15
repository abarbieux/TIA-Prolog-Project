extends Control


onready var current_team := $Current_Team
onready var Infos := [$Italie/VBoxContainer, $Hollande/VBoxContainer, $Belgique/VBoxContainer, $Allemagne/VBoxContainer]
onready var choose_player_panel := $ChoosePlayer
onready var current_cards_buttons := $Current_Cards




func display_deck_button(_team_deck: Array) -> void:
	var i = 0
	
	for carte in _team_deck:
		var button = Button.new()
		button.text = str(carte)
		button.rect_min_size.x = 85
		button.icon = preload("res://icon.png")
		current_cards_buttons.add_child(button)
		var c = button.connect("pressed", get_parent(), "_button_pressed", [button, carte, i])
		i += 1

func display_team_deck(_team_deck: Array,team: int):
	
	
	var i = 0
	var place
	
	place = Infos[team]
	for child in place.get_children():
				child.queue_free()
				
	for carte in _team_deck:
			var button = Button.new()
			
			button.text = str(carte)
			button.rect_size = Vector2(10,10)
			place.add_child(button)
			
			i += 1

func choose_player(value: int, index: int, cyclistes_movable: Array):
	get_parent().turn_already_past = false
	
	for kids in choose_player_panel.get_children():
		kids.queue_free()
	
	for cycliste in cyclistes_movable :
		var button = Button.new()
		button.text = str(cycliste.name)
		button.rect_min_size.x = 96
		button.icon = preload("res://icon.png")
		choose_player_panel.add_child(button)
		var c = button.connect("pressed", get_parent(), "_button_player_pressed", [cycliste, value, index])


