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

var currentClingSlideSpeed = 0

#Flap Count and Max Flax Count
var flapMax = 2
var flapCurrent = flapMax

#Bools
onready var is_grounded = false

#World Variables
export var frict = 0.6
export var gravity = 2.3

#FONT
onready var defFont = load("res://Assets/Font/defo.tres")

#Sprite
onready var playerSprite = get_node("AnimatedSprite")

#Areas
onready var areaLeft = get_node("LeftArea")
onready var areaRight = get_node("RightArea")
onready var areaTop = get_node("TopArea")
onready var areaBottom = get_node("BottomArea")

onready var areaClingLeft = get_node("LeftClingArea")
onready var areaClingRight = get_node("RightClingArea")

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
	var playerBody = get_node("BodyShape")
	
	if Input.is_action_pressed("ui_right"):
		areaClingRight.position.x = playerBody.position.x + 15
		pass
	elif Input.is_action_just_released("ui_right"):
		areaClingRight.position.x = playerBody.position.x 
		pass
			
	if Input.is_action_just_pressed("ui_left"):
		areaClingLeft.position.x = playerBody.position.x - 15
		pass
	elif Input.is_action_just_released("ui_left"):
		areaClingLeft.position.x = playerBody.position.x 
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
	currentMoveState = stateMovement.idle_ground
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
			velocityToAdd.y += jumpPower
				
	#IDLE_AIR
	elif currentMoveState == stateMovement.idle_air or currentMoveState == stateMovement.moving_air:
		
		if Input.is_action_pressed("ui_right"):
			velocityToAdd.x += acceleration
				
		if Input.is_action_pressed("ui_left"):
			velocityToAdd.x -= acceleration
		
		if Input.is_action_just_pressed("wingflap") and flapCurrent != 0:
				velocityToAdd.y = 0
				velocityToAdd.y += flapPower      
				
				flapCurrent -= 1
				 
	#WALL_CLING
	elif currentMoveState == stateMovement.wall_cling:
		#velocity.y = 0
		velocityToAdd.y = currentClingSlideSpeed
		pass
	
#Checks in proccess if states should be changed due to PlayerBody interactions
func  state_handle():
	
	#Check if dashing
	if velocityDash.x != 0 or velocityDash.y != 0:
		currentMoveState = stateMovement.dash
		pass

	#Check if any common movement states
	elif is_grounded:
		if velocity.x != 0:
			currentMoveState = stateMovement.moving_ground
		else:
			currentMoveState = stateMovement.idle_ground
	else:
		if velocity.x != 0:
			currentMoveState = stateMovement.moving_air
		else:
			currentMoveState = stateMovement.idle_air
			
		pass
		
		
	#Check if Cling Areas are in effect
	check_clingArea(areaClingRight)
	check_clingArea(areaClingLeft)
		
	pass

#Sets animation according to state and variables
func animation_handle():
	
	match currentMoveState:
		stateMovement.idle_ground:
			playerSprite.play("idle")
			
		stateMovement.moving_ground:
			playerSprite.play("run")
			
		stateMovement.idle_air, stateMovement.moving_air:
			playerSprite.play("jump")
			
		stateMovement.dash:
			playerSprite.play("dash")
		
		stateMovement.wall_cling:
			playerSprite.play("wallCling")
			
	pass

#Check cling area
func check_clingArea(area):
	if area.get_overlapping_areas().size() > 0:
		if area.get_overlapping_areas()[0].is_in_group(groupsTerrainArea.WALL_CLING):
			currentMoveState = stateMovement.wall_cling
			currentClingSlideSpeed =  area.get_overlapping_areas()[0].slipFactor * gravity
			pass
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
	
	#Don't add gravity if clinging or grounded
	if moveState == stateMovement.wall_cling:
		velocity.y = 0
	elif !is_grounded:
		velocity.y += gravity/7
		
	if moveState == stateMovement.moving_ground:
		friction_handle()
	#If correct state, check rubberband force
	
	
	pass

func _physics_process(delta):
	
	#Input handler event
	input_handle()
	
	#State handler
	state_handle()
	print(currentMoveState)
	
	#Animation handle
	animation_handle()
	
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

#Area of main body sides
func _on_TopArea_body_entered(_body):
	velocity.y = 0
	velocityToAdd.y = 0
	pass # Replace with function body.

func _on_BottomArea_body_entered(_area):
	is_grounded = true
	flapCurrent = flapMax
	
	print("aa")
	
	velocity.y = 0
	velocityToAdd.y = 0
	pass # Replace with function body.

func _on_LeftArea_body_entered(_area):
	velocity.x = 0
	velocityToAdd.x = 0
	pass 
	
func _on_RightArea_body_entered(_area):
	velocity.x = 0
	velocityToAdd.x = 0
	pass 


func _on_BottomArea_body_exited(_area):
	is_grounded = false
	#velocity.y = 0
	#velocityToAdd.y = 0
	
	print("bb")
	
	pass # Replace with function body.

	velocity.x = 0
	velocityToAdd.x = 0
	pass # Replace with function body.
