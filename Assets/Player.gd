extends Node2D

var bodyNode

#Custom functions#
func stateManager():
	
	pass
	
func input_handle():
	pass

func _ready():
	bodyNode = get_node("RigidBody2D")
	pass

func _process(delta):
	position = bodyNode.position
	pass