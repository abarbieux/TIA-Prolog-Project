class_name Cycliste
extends Sprite


var current_case := Vector2.ZERO
var pays: String = "belgique" # cas par default
var numero: int = 1
var fall: bool = false
var counter_fall: int = 0


func _ready() -> void:
	texture = load("res://Picture/Cyclistes/" + pays + "_" + str(numero) + ".png")


func _to_dict():
	return {"name":"%s_%s" % [pays, numero], "current_case": "[%s, %s]" % [current_case.x, current_case.y], "pays": pays, "numero": numero, "fall": fall, "counter_fall": counter_fall}


func _to_string():
	return "x:%s y:%s pays:%s numero:%s fall:%s counter_fall:%s" % [current_case.x, current_case.y, pays, numero, fall, counter_fall]
