class_name Cycliste
extends Sprite


var current_case := Vector2.ZERO
var pays: String = "belgique" # cas par default
var numero: int = 1
var fall: bool = false
var counter_fall: int = 0


func _ready() -> void:
	texture = load("res://Picture/Cyclistes/" + pays + "_" + str(numero) + ".png")
