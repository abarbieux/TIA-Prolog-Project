extends Node
class_name GameWebSocket

# The URL we will connect toy
export var websocket_url = "ws://127.0.0.1:5000/ws"
# Our WebSocketClient instance
var _client = WebSocketClient.new()
var panel
var functions = ["getPosition", "conseilCarte", "isMoveAutorised"]
var instance
var deck_cache


func _init(_instance):
	instance = _instance


func _ready():
	OS.execute("swipl", ["-s", "./GameChatServer.pl"], false)
	
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data")

	var err = _client.connect_to_url(websocket_url)
	print("Starting Game Server")
	if err != OK:
		print("Unable to connect")
		set_process(false)


func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	set_process(false)


func _connected(_proto = ""):
	pass


func _on_data():
	if panel == null:
		return
	var message = _client.get_peer(1).get_packet().get_string_from_utf8()
	print(message)
	if _check_liability(message):
		var args = Array(message.split(" "))
		var command = args[0].replace(" ", "").replace("\"", "")
		args = args.slice(1, len(args))
		var result_message = "Cette fonction n'est pas encore implémentée..."
		var send_message = true
		match command:
			"getPosition":
				var country
				var cyclist_number
				print(args)
				for arg in args:
					if "country:" in arg:
						country = arg.replace("country:", "").replace("\"", "")
					elif "number:" in arg:
						cyclist_number = int(arg.replace("number:", "").replace("\"", ""))
				var result = instance._ChatBotAI.get_cyclist_position(country, cyclist_number)
				print(result)
				if result != Vector2(-1.0, -1.0):
					result_message = "La position du joueur %s de l'équipe %s est %s" % [cyclist_number, country, result]
				else:
					result_message = "Le joueur %s de l'équipe %s n'est pas sur le plateau ou n'existe pas..." % [cyclist_number, country]
			"conseilCarte":
				if len(instance._MovementManager.get_last_cyclist_movable()) > 0:
					var result = instance._ChatBotAI.get_best_card(instance.countries[instance._country_turn_index].name)
					result_message = "La meilleure carte à jouer de l'équipe %s du joueur %s est la carte avec une valeur de %s" % [instance.countries[instance._country_turn_index].name, instance._MovementManager.get_last_cyclist_movable()[0].numero, result]
				else:
					result_message = "La demande de conseil pour la team %s ne peut aboutir..." % instance.countries[instance._country_turn_index]
			"isMoveAutorised":
				var card_to_play = int(args[0])
				if len(instance._MovementManager.get_available_cells(card_to_play)) == 0:
					var country = instance._MovementManager.get_last_cyclist_movable()[0].pays
					deck_cache.append(card_to_play)
					var buffer = instance._GameAI.get_game_information_dict()
					var new_deck = buffer["teams_deck"][country]
					for cached_card in deck_cache:
						new_deck = instance._GameAI.remove_card_from_deck(new_deck, cached_card)
					buffer["teams_deck"][country] = new_deck
					if len(new_deck) > 0:
						_client.get_peer(1).put_packet(("AI " + JSON.print(buffer)).to_utf8())
					else:
						card_to_play = instance._ChatBotAI.get_best_card_h0(country)
				instance._button_player_pressed(instance._MovementManager.get_last_cyclist_movable()[0], card_to_play, 0)
				send_message = false
		if send_message:
			panel._on_Message_received(result_message)
	else:
		panel._on_Message_received(message)


func _process(_delta):
	_client.poll()


func _exit_tree():
	_client.disconnect_from_host()
	

func _check_liability(message):
	var args = message.replace("\"", "").split(" ")
	return args[0] in functions
