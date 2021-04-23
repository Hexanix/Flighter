extends Area2D

#onready var groupsTerrain = get_node("/root/groupsTerrainType")
onready var groupsTerrainArea = get_node("/root/groupsTerrainArea")

#Area-specific variables
<<<<<<< HEAD
export var slipFactor = 0.55
=======
export var slipFactor = 0.5
>>>>>>> parent of 86f9f74 (Move To Action change)

func group_adding():
	#WallCling
	add_to_group(groupsTerrainArea.WALL_CLING)
	pass

func _ready():
	#Add to groups
	group_adding()
	
	pass

func _process(delta):
	
	pass
