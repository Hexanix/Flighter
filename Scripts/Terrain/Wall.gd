extends StaticBody2D

onready var groupsTerrain = get_node("/root/groupsTerrainType")
onready var groupsTerrainArea = get_node("/root/groupsTerrainArea")


func group_adding():
	#Wall
	add_to_group(groupsTerrain.GENERAL)
	pass

func _ready():
	#Add to groups
	group_adding()
	
	pass

func _process(delta):
	
	pass
