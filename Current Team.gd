extends Label

var New_Team: String = "Italie"

func _process(delta: float) -> void:
	set("custom_colors/font_color", Color(0,0,0))
	set_text(("Turn of ") + String(New_Team))

func _on_Main_Change_turn(Team) -> void:
	New_Team = Team
