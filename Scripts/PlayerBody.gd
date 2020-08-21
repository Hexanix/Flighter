extends KinematicBody2D

#Velocity Vars#
var velocity = Vector2(0, 0)
var velocityToAdd = Vector2(0, 0)
var velocityDash = Vector2(0, 0)

var velocity_HorLimit = Vector2(0, 0)
var velocity_VerLimit = Vector2(0, 0)

#Character Variables
export var acceleration = 1
export var dashPower = 25
export var dashSlowdown = 2

export var jumpPower = 1.4
export var flapPower = 1

var speedHorizontal = 5000
var speedVertical = 100000

#Bools
var is_clinging = false

#World Variables
export var frict = 0.6
export var gravity = 2.3

#Singletons
onready var groupsTerrain = get_node("/root/groupsTerrainType")
onready var groupsTerrainArea = get_node("/root/groupsTerrainArea")

#States of the player, both variants#
enum stateMovement{ 
	idle_air,
	idle_ground, 
	moving_air, 
	moving_ground, 
	wall_cling
	dash
}

enum stateAction{
	neutral,
	attack,
	parry
}

var currentMoveState
var currentActionState

#Function which sets the position of Area2D side to the edge of PlayerBody 
func areaClingHandle():
	var areaBodyLeft = get_node("LeftArea/LeftShape")
	var areaBodyRight = get_node("RightArea/RightShape")
	var playerBody = get_node("BodyShape")
	
	if Input.is_action_pressed("ui_right"):
		areaBodyRight.position.x = playerBody.position.x + 30
		pass
	elif Input.is_action_just_released("ui_right"):
		areaBodyRight.position.x = playerBody.position.x 
		pass
			
	if Input.is_action_just_pressed("ui_left"):
		areaBodyLeft.position.x = playerBody.position.x - 30
		pass
	elif Input.is_action_just_released("ui_left"):
		areaBodyLeft.position.x = playerBody.position.x 
		pass


#System functions
func _ready():
	#Movement units are multiplied by 1000 to use with delta#
	acceleration *= speedHorizontal
	frict *= speedHorizontal
	
	dashPower *= speedHorizontal
	dashSlowdown *= speedHorizontal
	
	#jumpPower *= gravity/1.4
	jumpPower *= -speedVertical
	
	
	flapPower *= -speedVertical
	flapPower -= gravity
	
	gravity *= speedVertical/15
	
	
	#Velocity initialized#
	velocity_HorLimit = Vector2(acceleration*-8,acceleration*8);
	velocity_VerLimit = Vector2(speedVertical*-0.7, gravity*5)
	velocity = Vector2(0, 0)
	
	
	#We start midair#
	currentMoveState = stateMovement.idle_air
	currentActionState = stateAction.neutral
	pass

#Custom functions
func input_handle():
	
	#HANDLE AREAS 
	areaClingHandle()
	
	#Check state and determine calculations
	#DASH 
	if Input.is_action_just_pressed("dash"):
		if Input.is_action_pressed("ui_left"):
			velocityDash.x -= dashPower
		elif Input.is_action_pressed("ui_right"):
			velocityDash.x += dashPower

	#IDLE_GROUND
	if currentMoveState == stateMovement.idle_ground or currentMoveState == stateMovement.moving_ground:
		if Input.is_action_pressed("ui_right"):
			velocityToAdd.x += acceleration
				
		if Input.is_action_pressed("ui_left"):
			velocityToAdd.x -= acceleration
		
		if Input.is_action_just_pressed("wingflap"):
			#velocityToAdd.y = 0
			velocityToAdd.y += jumpPower
				
	#IDLE_AIR
	elif currentMoveState == stateMovement.idle_air or currentMoveState == stateMovement.moving_air:
		
		if Input.is_action_pressed("ui_right"):
			velocityToAdd.x += acceleration
				
		if Input.is_action_pressed("ui_left"):
			velocityToAdd.x -= acceleration
		
		if Input.is_action_just_pressed("wingflap"):
				velocityToAdd.y = 0
				velocityToAdd.y += flapPower      
				 
	#WALL_CLING
	elif currentMoveState == stateMovement.wall_cling:
		pass
	
#Checks in proccess if states should be changed due to PlayerBody interactions
func state_handle():
	#If it is not changed, it stays in the air.
	if velocityDash.x != 0 or velocityDash.y != 0:
		currentMoveState = stateMovement.dash
		pass
	
	#Set initial state to airborne
	if velocity.y != 0 and currentMoveState != stateMovement.wall_cling:
		if velocity.x != 0:
			currentMoveState = stateMovement.moving_air
		else:
			currentMoveState = stateMovement.idle_air
			pass
			
		pass
	
	#Check if colliding with any terrain
	for i in range(get_slide_count()):
		var currentCollider = get_slide_collision(i).get_collider()
		
		#GROUND
		if currentCollider.is_in_group(groupsTerrain.GROUND):
			velocity.y = 0
			
			if velocity.x == 0:
				currentMoveState = stateMovement.idle_ground
				return
				pass
			else:
				currentMoveState = stateMovement.moving_ground
				return
				pass
				
		#WALL
		elif currentMoveState == stateMovement.wall_cling:
			print("woa")
			velocity.y = 0
			velocityToAdd.y = 0
			pass
	pass

#Friction handle
func friction_handle():
	if velocity.x > 0:
		velocityToAdd.x -= frict
		if velocity.x - frict < 0:
			velocityToAdd.x  = -velocity.x
	elif velocity.x < 0:
		velocityToAdd.x  += frict
		if velocity.x + frict > 0:
			velocityToAdd.x  = -velocity.x
	pass

#Dash slowdown handle
func dash_handle():
	velocity += velocityDash
	
	#Dash downwind
	if velocityDash.x > 0:
		velocityDash.x -= dashSlowdown
		if velocityDash.x - dashSlowdown < 0:
			velocityDash.x  = 0
	elif velocityDash.x < 0:
		velocityDash.x += dashSlowdown
		if velocityDash.x + frict > 0:
			velocityToAdd.x  = 0
	pass

#Includes:
#	- Friction
#	- Dash slowdown - NOT WORKING IN THIS FUNCTION
#	- Gravity
func natural_forces_handle(moveState):
	#Add Gravity. Number dividing represents how slowly gravity will stack.
	velocityToAdd.y += gravity/7
	
	#If correct state, check rubberband force
	if moveState == stateMovement.moving_ground:
		friction_handle()
	elif moveState == stateMovement.wall_cling:
		velocity.y = 0
		velocityToAdd.y = 0
	
	pass

func _physics_process(delta):
	
	#Input handler event
	input_handle()
	
	#State handler
	state_handle()
	print(currentMoveState)
	
	#Handle rubberbanding of movement
	natural_forces_handle(currentMoveState)

	#Regulate velocity
	velocity.x += velocityToAdd.x
	velocity.y += velocityToAdd.y
	
	#Have a separate velocity for dashing, which is added post-clamp
	#and has a different rubberbanding force than normal movement
	velocity.y = clamp(velocity.y, velocity_VerLimit.x, velocity_VerLimit.y)
	velocity.x = clamp(velocity.x, velocity_HorLimit.x, velocity_HorLimit.y)
	
	#Dash Handling happens here for now.
	dash_handle()
	
	#Move 
	move_and_slide(velocity*delta)
	
	#Reset velToAdd variable
	velocityToAdd.x = 0
	velocityToAdd.y = 0

	
	pass

#SIGNALS

#Checks in proccess if states should be changed due to AREA interactions
#Area-On-Area collision handling

#Switch state and change is_clinging bool (might be obsolete)
func _on_RightArea_area_entered(area):
	
	if area.is_in_group(groupsTerrainArea.WALL_CLING):
		print("right")
		#velocity.y = area.slipFactor
		currentMoveState = stateMovement.wall_cling
		is_clinging = true
		pass 

func _on_LeftArea_area_exited(area):
	
	if area.is_in_group(groupsTerrainArea.WALL_CLING):
		print("off-left")
		
		currentMoveState = stateMovement.idle_air
		is_clinging = false
		pass # Replace with function body.

func _on_LeftArea_area_entered(area):
	if area.is_in_group(groupsTerrainArea.WALL_CLING):
		print("left")
		#velocity.y = area.slipFactor
		currentMoveState = stateMovement.wall_cling
		is_clinging = true
		pass 

func _on_RightArea_area_exited(area):
	if area.is_in_group(groupsTerrainArea.WALL_CLING):
		print("off-right")
		#velocity.y = area.slipFactor
		
		currentMoveState = stateMovement.idle_air
		is_clinging = false
		pass # Replace with function body.
