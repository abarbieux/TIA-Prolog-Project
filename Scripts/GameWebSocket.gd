extends Node

# The URL we will connect to
export var websocket_url = "ws://127.0.0.1:5000/ws"

# Our WebSocketClient instance
var _client = WebSocketClient.new()

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
	print("Connected with protocol: ", proto)
	_client.get_peer(1).put_packet("Test packet".to_utf8())

func _on_data():
	print("Got data from game server: ", _client.get_peer(1).get_packet().get_string_from_utf8())


func _process(delta):
	_client.poll()


func _exit_tree():
	_client.disconnect_from_host()
