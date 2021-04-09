extends Node
class_name Action

#Universal variables

#Does the action lock the player in one place?
var is_locked : bool = false

#Determines type of action, is set in children
enum actionType {
	attack,
	parry,
	neutral
}

var _type : int setget set_type, get_type

func set_type(var tp: int) -> void:
	if tp > actionType.size():
		_type = tp
		pass
	else:
		print("No such index exists in enum actionType")
	pass
 
func get_type() -> int:
	return _type
	pass
	


