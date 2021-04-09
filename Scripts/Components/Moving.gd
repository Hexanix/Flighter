extends Node2D

var weight : float = 0 setget set_weight, get_weight
func set_weight(w: float) -> bool:
	if w >= 1:
		weight = w
		return true
		pass
	else:
		return false
	pass
func get_weight() -> float:
	return weight
	pass

var jumpPower : float = 0 setget set_jumpPower, get_jumpPower
func set_jumpPower(w: float) -> bool:
	if w >= 0:
		jumpPower = w
		return true
		pass
	else:
		return false
	pass
func get_jumpPower() -> float:
	return jumpPower
	pass

var acceleration : float = 0 setget set_acceleration, get_acceleration
func set_acceleration(w: float) -> bool:
	if w >= 1:
		acceleration = w
		return true
		pass
	else:
		return false
	pass
func get_acceleration() -> float:
	return acceleration
	pass

var velocity : Vector2 = Vector2(0, 0)
func velocityMerge():
	velocity = velocityToAdd
	pass

var velocityToAdd : Vector2 = Vector2(0, 0)

func velocityToAdd_toX(var x:float):
	velocityToAdd.x += x
	pass
func velocityToAdd_toY(var y:float):
	velocityToAdd.y += y
	pass

var naturalSpeedLimit : Vector2 = Vector2(0, 0) 
func set_naturalSpeedLimit(x: float, y: float) -> bool:
	if x >= 1 and y >= 1:
		naturalSpeedLimit.x = x
		naturalSpeedLimit.y = y
		return true
		pass
	else:
		return false
	pass

var affectedSpeedLimit : Vector2 = Vector2(0, 0)
func set_affectedSpeedLimit(x: float, y: float) -> bool:
	#Affected speed has to be higher than the normal one
	if x >= naturalSpeedLimit.x and y >= naturalSpeedLimit.y:
		affectedSpeedLimit.x = x
		affectedSpeedLimit.y = y
		return true
		pass
	else:
		return false
	pass

#Quick function to set all the variables
func set_all(w : float, jp: float, ac: float) -> void:
	weight = w
	jumpPower = jp
	acceleration = ac
	pass


