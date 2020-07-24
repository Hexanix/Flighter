extends StaticBody2D
var varNode

func group_adding():
	
	#Ground
	add_to_group(varNode.getValue(
	varNode.fromTerrainGroups(), 
	varNode.fromTerrainGroups().ground))
	
	
	pass

func _ready():
	varNode = get_node("../VarNodes/Groups")
	group_adding()                                                                                                                                                                                                                                                                                                    
	
	pass

func _process(delta):
	
	pass
