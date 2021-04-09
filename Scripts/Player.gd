extends Node2D

#Velocity Vars#
var velocity = Vector2(0, 0)
var velocityToAdd = Vector2(0, 0)
var velocityDash = Vector2(0, 0)

var velocity_HorLimit = Vector2(0, 0)
var velocity_VerLimit = Vector2(0, 0)

#Character Variables
export var acceleration : float = 1
export var dashPower : float = 25
export var dashSlowdown : float = 2

export var jumpPower : float =  1.4
export var flapPower : float = 1

var speedHorizontal : int = 5000
var speedVertical : int = 100000

var currentClingSlideSpeed : float = 0

#Flap Count and Max Flax Count
var flapMax : int = 2
var flapCurrent : int = flapMax

#Bools
onready var is_grounded : bool = false

#World Variables
export var frict : float= 0.6
export var gravity : float = 2.3

#Sprites
onready var playerSprite : Node = get_node("playerBody/playerSprite")

#Areas
onready var areaLeft : Node = get_node("playerBody/LeftArea")
onready var areaRight : Node = get_node("playerBody/RightArea")
onready var areaTop : Node = get_node("playerBody/TopArea")
onready var areaBottom : Node = get_node("playerBody/BottomArea")

onready var areaClingLeft : Node = get_node("playerBody/LeftClingArea")
onready var areaClingRight : Node = get_node("playerBody/RightClingArea")

#Singletons
onready var groupsTerrain : Node = get_node("/root/groupsTerrainType")
onready var groupsTerrainArea : Node = get_node("/root/groupsTerrainArea")

#States of the player, both variants#
enum stateMovement{ 
	idle_air,
	idle_ground, 
	moving_air, 
	moving_ground, 
	dash
}

enum stateAction{
	neutral,
	attack,
	wall_cling
	attack_up,
	parry
}

export var currentMoveState : int = stateMovement.idle_ground
export var currentActionState : int = stateAction.neutral

#Function which sets the position of Area2D side to the edge of PlayerBody 
func areaClingHandle() -> void:
	var playerBody = get_node("playerBody/BodyShape")
	
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
func _ready()  -> void:
	
	#Movement units are multiplied by 1000 to use with delta#
	acceleration *= speedHorizontal
	frict *= speedHorizontal
	
	dashPower *= speedHorizontal
	dashSlowdown *= speedHorizontal
	
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
func input_handle() -> void:
	
	#HANDLE AREAS 
	areaClingHandle()
	
	#WALL_CLING Action
	if currentActionState == stateAction.wall_cling:
		#velocity.y = 0
		velocityToAdd.y += currentClingSlideSpeed
		pass
	
	#Check if action state is neutral branch
	if currentActionState != stateAction.parry and currentActionState != stateAction.attack_up:
		
		#No h_flip while attacking, only movement
		if currentActionState != stateAction.attack:
			#Flip sprite
			if Input.is_action_pressed("ui_left"):
				playerSprite.set_flip_h(true)
				pass
			elif Input.is_action_pressed("ui_right"):
				playerSprite.set_flip_h(false)
				pass
		pass
		
		#Check state and determine calculations
		#DASH 
		if Input.is_action_just_pressed("dash"):
			
			if Input.is_action_pressed("ui_left"):
				velocityDash.x -= dashPower
			elif Input.is_action_pressed("ui_right"):
				velocityDash.x += dashPower
				
		#ATTACK - direct state change currently
		if Input.is_action_just_pressed("attack"):
			
			if Input.is_action_pressed("ui_up"):
				currentActionState = stateAction.attack_up
			else:
				currentActionState = stateAction.attack
			pass
	
		#GROUND
		if currentMoveState == stateMovement.idle_ground or currentMoveState == stateMovement.moving_ground:
			if Input.is_action_pressed("ui_right"):
				velocityToAdd.x += acceleration
					
			if Input.is_action_pressed("ui_left"):
				velocityToAdd.x -= acceleration
			
			if Input.is_action_just_pressed("wingflap"):
				velocityToAdd.y += jumpPower
					
		#AIR
		elif currentMoveState == stateMovement.idle_air or currentMoveState == stateMovement.moving_air:
			
			#Gravitational Pull
			velocityToAdd.y += gravity/7
			
			if Input.is_action_pressed("ui_right"):
				velocityToAdd.x += acceleration
					
			if Input.is_action_pressed("ui_left"):
				velocityToAdd.x -= acceleration
			
			if Input.is_action_just_pressed("wingflap") and flapCurrent != 0:
					velocityToAdd.y = 0
					velocityToAdd.y += flapPower      
					
					flapCurrent -= 1
					 
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
#TODO: playerBody/playerAnimation 
func animation_handle():
	
	match currentActionState:
		stateAction.attack:
			$playerBody/playerAnimation.play("attack")
		
		stateAction.attack_up:
			$playerBody/playerAnimation.play("attackUp")
			
		stateAction.wall_cling:		
			$playerBody/playerAnimation.play("wallCling")
			
		
		stateAction.neutral:
			match currentMoveState:
				
				stateMovement.idle_ground:
					$playerBody/playerAnimation.play("idle")
					
				stateMovement.moving_ground:
					$playerBody/playerAnimation.play("run")
					
				stateMovement.idle_air, stateMovement.moving_air:
					$playerBody/playerAnimation.play("jump")
					
				stateMovement.dash:
					$playerBody/playerAnimation.play("dash")

				stateMovement.idle_ground:
					$playerBody/playerAnimation.play("idle")
				
				stateMovement.moving_ground:
					$playerBody/playerAnimation.play("run")
					
				stateMovement.dash:
					$playerBody/playerAnimation.play("slide")
				
				stateMovement.idle_air, stateMovement.moving_air:
					$playerBody/playerAnimation.play("jump")
					

	
	pass

#Method used by AnimationPlayer to reset the state at the end of animation 
func actionState_neutral():
	currentActionState = stateAction.neutral
	pass

#Check cling area
func check_clingArea(area):
	#Quick hack
	if currentActionState == stateAction.wall_cling:
		currentActionState = stateAction.neutral
	
	if area.get_overlapping_areas().size() > 0:
		if area.get_overlapping_areas()[0].is_in_group(groupsTerrainArea.WALL_CLING):
			
			currentActionState = stateAction.wall_cling
			var slipFactor = area.get_overlapping_areas()[0].slipFactor
			
			#Experimental!
			if velocity.y > slipFactor:
				currentClingSlideSpeed = slipFactor/-3 * gravity
			elif velocity.y < slipFactor:
				currentClingSlideSpeed = slipFactor/3 *gravity
			else:
				currentClingSlideSpeed =  slipFactor * gravity
			pass
		pass
	pass
	

#Make all these handles use the same method please

#This is supposed to be a generic function, but Godot makes it not work and frankly I can't be bothered looking 
#up why, so code stays lengthy and silly now, fucking sue me.
func genericRubberband_handler(varToTest, varToAdd, rubberbandForce, pivotVariable):
		if varToTest > pivotVariable:
			varToAdd -= rubberbandForce
			if varToTest - rubberbandForce < pivotVariable:
				varToAdd  = -varToTest
		elif varToTest < pivotVariable:
			varToAdd  += rubberbandForce
			if varToTest + rubberbandForce > pivotVariable:
				varToAdd = -varToTest
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
func natural_forces_handle(moveState: int) -> void:
		
	if moveState == stateMovement.moving_ground:
		friction_handle()
	#If correct state, check rubberband force
	
	
	pass

func _physics_process(delta):
	
	#Input handler event
	input_handle()
	
	#State handler
	state_handle()
	
	if currentMoveState == 4:
		print(velocityToAdd.y*1.0)
	
	#Animation handle
	#Play correct animation according to state
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
	$playerBody.move_and_slide(velocity*delta)
	
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
	velocityDash.x = 0
	pass 
	
func _on_RightArea_body_entered(_area):
	velocity.x = 0
	velocityToAdd.x = 0
	velocityDash.x = 0
	pass 



func _on_BottomArea_body_exited(_area):
	is_grounded = false
	#velocity.y = 0
	#velocityToAdd.y = 0
	
	print("bb")
	
	pass # Replace with function body.
