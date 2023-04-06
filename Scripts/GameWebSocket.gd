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
	if _check_liability(message):
		var args = message.split(";")
		match args[0].replace(" ", "").replace("\"", ""):
			"getPosition":
				print("Get Position of %s at %s", args[1], args[2])
			"conseilCarte":
				if len(instance.get_last_cyclist_movable(instance.Countries[instance._country_turn_index])) > 0:
					# conseilCarte($Main.Countries[$Main._country_turn_index], $Main.get_last_cyclist_movable($Main.Countries[$Main._country_turn_index])[0])
					print("Demande de conseil pour la carte à jouer de l'équipe %s du joueur %s" % [instance.Countries[instance._country_turn_index], instance.get_last_cyclist_movable(instance.Countries[instance._country_turn_index])[0].numero])
				else:
					print("La demande de conseil pour la team %s ne peut aboutir..." % instance.Countries[instance._country_turn_index])
	else:
		panel._on_Message_received(message)


func _process(delta):
	_client.poll()


func _exit_tree():
	_client.disconnect_from_host()
	

func _check_liability(message):
	var args = message.replace(" ", "").replace("\"", "").split(";")
	return args[0] in functions
