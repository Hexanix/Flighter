extends StaticBody2D

#nodes for varNodes
var varNode_Group

#Terrain-specific variables
export var slipFactor = 0


func group_adding(var varNode):	
	#Wall
	add_to_group(varNode.getValue(
	varNode.fromTerrainGroups(), 
	varNode.fromTerrainGroups().wall))
	pass

func _ready():
	#get varNodes
	varNode_Group = get_node("../VarNodes/Groups")
	
	#Add to groups
	group_adding(varNode_Group)
	pass

func _process(delta):
	
	pass
