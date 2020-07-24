extends Node

enum terrainGroups{
	ground,
	wall,
	spikes,
	ceiling
}

func getValue(var enumObj, var enumValue):
	return enumObj.keys()[enumValue]
	pass

func fromTerrainGroups():
	return terrainGroups
	pass

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
