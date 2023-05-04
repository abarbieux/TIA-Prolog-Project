extends Control

onready var main = get_parent()

onready var Countries : Array = main.countries



func _on_OkButton_pressed() -> void:
	self.hide()
	main.init_pre_select_move_phase()
	


func _on_MenuButtonAllemagne_item_selected(index: int) -> void:
	change_tactic(Countries[3], index)


func _on_MenuButtonBelgique_item_selected(index: int) -> void:
	change_tactic(Countries[2], index)


func _on_MenuButtonHollande_item_selected(index: int) -> void:
	change_tactic(Countries[1], index)


func _on_MenuButtonItalie_item_selected(index: int) -> void:
	change_tactic(Countries[0], index)

func change_tactic(country, index: int) -> void:
	country.Tactic = index
	print(country.Tactic)
