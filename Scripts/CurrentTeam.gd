extends Label


var new_team: String = "Italie"


func _ready() -> void:
	set("custom_colors/font_color", Color(0,0,0))


func change_text(_new_team: String) -> void:
	set_text(("Turn of ") + _new_team)
