extends Node
class_name GameWebSocket

# The URL we will connect toy
export var websocket_url = "ws://127.0.0.1:5000/ws"
# Our WebSocketClient instance
var _client = WebSocketClient.new()
var panel
var functions = ["getPosition", "conseilCarte"]
var instance


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


func _connected(proto = ""):
	pass


func _on_data():
	if panel == null:
		return
	var message = _client.get_peer(1).get_packet().get_string_from_utf8()
	print(message)
	if _check_liability(message):
		var args = message.split(";")
		var result_message = "Cette fonction n'est pas encore implémentée..."
		match args[0].replace(" ", "").replace("\"", ""):
			"getPosition":
				var args_1 = args[1].replace(" ", "").replace("\"", "")
				var args_2 = args[2].replace(" ", "").replace("\"", "")
				var result = instance._ChatBotAI.get_cyclist_position(args_1, args_2)
				if result != Vector2(-1.0, -1.0):
					result_message = "La position du joueur %s de l'équipe %s est %s" % [args_2, args_1, result]
				else:
					result_message = "Le joueur %s de l'équipe %s n'est pas sur le plateau ou n'existe pas..." % [args_2, args_1]
			"conseilCarte":
				if len(instance._MovementManager.get_last_cyclist_movable()) > 0:
					var result = instance._ChatBotAI.get_best_card(instance.countries[instance._country_turn_index].name)
					result_message = "La meilleure carte à jouer de l'équipe %s du joueur %s est la carte avec une valeur de %s" % [instance.countries[instance._country_turn_index].name, instance._MovementManager.get_last_cyclist_movable()[0].numero, result]
				else:
					result_message = "La demande de conseil pour la team %s ne peut aboutir..." % instance.countries[instance._country_turn_index]
		panel._on_Message_received(result_message)
	else:
		panel._on_Message_received(message)


func _process(delta):
	_client.poll()


func _exit_tree():
	_client.disconnect_from_host()
	

func _check_liability(message):
	var args = message.replace(" ", "").replace("\"", "").split(";")
	return args[0] in functions
