extends StaticBody2D


onready var groupsTerrain = get_node("/root/groupsTerrainType")
onready var groupsTerrainArea = get_node("/root/groupsTerrainArea")

func group_adding():	
	#Ground
	add_to_group(groupsTerrain.GROUND)
	
	pass

func _ready():
	group_adding()                                                                                                                                                                                                                                                                                                    
	
	pass

func _process(delta):
	
	pass
