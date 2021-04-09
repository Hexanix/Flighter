extends "res://Scripts/Components/Moving.gd"

export var flapPower : float = 1 
export var dashPower : float = 25
export var dashSlowdown : float = 2

func _ready():
	set_all(1, 1.4, 1)
	set_naturalSpeedLimit(3, 6)
	set_affectedSpeedLimit(5, 8)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
