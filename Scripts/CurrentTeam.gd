extends Label


var New_Team: String = "Italie"


func _ready() -> void:
	set("custom_colors/font_color", Color(0,0,0))


func change_text(New_Team: String) -> void:
	set_text(("Turn of ") + New_Team)
