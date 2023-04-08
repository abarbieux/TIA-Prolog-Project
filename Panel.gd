extends Panel

onready var _LineEdit = $LineEdit
onready var Text_Edit = $TextEdit
var _GameWebSocket
var _Text = ""

func _ready() -> void:
	_LineEdit.connect("text_entered", self, "_on_Text_entered")


func _on_Message_received(received_text) -> void:
	_Text = _Text + "ChatBot: " + received_text + "\n"
	_Modify_Text(_Text)


func _on_Send_pressed() -> void:
	_GameWebSocket._client.get_peer(1).put_packet(_LineEdit.get_text().to_utf8())
	_Text = _Text + "Moi: " + _LineEdit.get_text() + "\n"
	_LineEdit.set_text("")
	_Modify_Text(_Text)


func _on_Text_entered(new_text) -> void:
	_GameWebSocket._client.get_peer(1).put_packet(new_text.to_utf8())
	_Text = _Text + "Moi: " + _LineEdit.get_text() + "\n"
	_LineEdit.set_text("")
	_Modify_Text(_Text)


func _Modify_Text(new_text) -> void:
	Text_Edit.set_text(new_text)

