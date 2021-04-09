extends "res://Scripts/Characters/PlayerActions/Action.gd"
class_name ParryAction

#Action specific variables
var knockback : float = 0.2

# Called when the node enters the scene tree for the first time.
func _ready():
	is_locked = true
	_type = actionType.parry 
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
