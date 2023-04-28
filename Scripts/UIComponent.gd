extends Control


onready var current_team := $Current_Team
onready var Infos := [$Italie/HBoxContainer, $Hollande/HBoxContainer, $Belgique/HBoxContainer, $Allemagne/HBoxContainer]
onready var choose_player_panel := $ChoosePlayer
onready var current_cards_buttons := $Current_Cards
onready var bonus_logs := $Bonus_History


func display_deck_button(_team_deck: Array) -> void:
	var i = 0
	
	for carte in _team_deck:
		var button = TextureButton.new()
		button.rect_min_size.x = 60


		
		var image_path : String = ("res://Picture/Cards/" + str(carte) + ".png")
		var image_selected_path : String = ("res://Picture/Cards/" + str(carte) + "_selected.png")
		
		var texture : Texture = load(image_path)
		var texture_selected : Texture = load(image_selected_path)
		
		button.expand = true
		button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT
		button.set_normal_texture(texture)
		button.set_pressed_texture(texture_selected)
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
			var card = TextureRect.new()
			card.rect_min_size.x = 50
			card.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
			card.texture = load("res://Picture/Cards/" + str(carte) + ".png")
			card.expand = true
			#card.rect_size = Vector2(102,136)
			place.add_child(card)
			#card.size = Vector2(50,75)
			#cards.text = str(carte)
			#cards.rect_size = Vector2(10,10)
			#place.add_child(cards)
			
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


