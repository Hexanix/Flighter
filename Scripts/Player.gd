extends Node2D

# class member variables go here, for example:
var nodePlayerBody


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	nodePlayerBody = get_node("RigidBody2D")
	pass

func _process(delta):
	position = nodePlayerBody.position
	pass
