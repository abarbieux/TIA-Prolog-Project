class_name Cycliste
extends Sprite


var CurrentCase := Vector2.ZERO
var Pays:String = "belgique" # cas par default
var numero:int = 1
var Fall:bool = false
var Counter_Fall:int = 0


func _ready() -> void:
	texture = load("res://Picture/Cyclistes/" + Pays + "_" + str(numero) + ".png")
