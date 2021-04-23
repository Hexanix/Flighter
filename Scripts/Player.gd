extends Node2D

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

<<<<<<< HEAD
var currentClingSlideFactor : float = 0
=======
var currentClingSlideSpeed = 0
>>>>>>> parent of 86f9f74 (Move To Action change)

#Flap Count and Max Flax Count
var flapMax = 2
var flapCurrent = flapMax

#Bools
onready var is_grounded = false

#World Variables
export var frict = 0.6
export var gravity = 2.3

#Sprites
onready var playerSprite = get_node("playerBody/playerSprite")

#Areas
onready var areaLeft = get_node("playerBody/LeftArea")
onready var areaRight = get_node("playerBody/RightArea")
onready var areaTop = get_node("playerBody/TopArea")
onready var areaBottom = get_node("playerBody/BottomArea")

<<<<<<< HEAD
onready var clingArea : Node = get_node("playerBody/ClingArea")
=======
onready var areaClingLeft = get_node("playerBody/LeftClingArea")
onready var areaClingRight = get_node("playerBody/RightClingArea")
>>>>>>> parent of 86f9f74 (Move To Action change)

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
	attack_up,
	parry
}

export var currentMoveState = stateMovement.idle_ground
export var currentActionState = stateAction.neutral

#Function which sets the position of Area2D side to the edge of PlayerBody 
func areaClingHandle():
	var playerBody = get_node("playerBody/BodyShape")
	
	if Input.is_action_pressed("ui_right"):
		clingArea.position.x = playerBody.position.x + 30
		pass
	elif Input.is_action_just_released("ui_right"):
		clingArea.position.x = playerBody.position.x 
		pass
			
	if Input.is_action_just_pressed("ui_left"):
		clingArea.position.x = playerBody.position.x - 30
		pass
	elif Input.is_action_just_released("ui_left"):
		clingArea.position.x = playerBody.position.x 
		pass

<<<<<<< HEAD
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

=======
>>>>>>> parent of 86f9f74 (Move To Action change)

#System functions
func _ready():
	
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
func input_handle():
	
	#HANDLE AREAS 
	areaClingHandle()
	
<<<<<<< HEAD
	#WALL_CLING Action
	#print(currentActionState)
	
=======
>>>>>>> parent of 86f9f74 (Move To Action change)
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
			
<<<<<<< HEAD
			#Gravitational Pull
			#velocityToAdd.y += gravity/7
			
=======
>>>>>>> parent of 86f9f74 (Move To Action change)
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
		
		
		
	pass

#Sets animation according to state and variables
#TODO: playerAnimation 
func animation_handle():
	
	match currentActionState:
		stateAction.attack:
			$playerAnimation.play("attack")
		
		stateAction.attack_up:
			$playerAnimation.play("attackUp")
		
		stateAction.neutral:
			match currentMoveState:
				
				stateMovement.idle_ground:
					$playerAnimation.play("idle")
					
				stateMovement.moving_ground:
					$playerAnimation.play("run")
					
				stateMovement.idle_air, stateMovement.moving_air:
					$playerAnimation.play("jump")
					
				stateMovement.dash:
					$playerAnimation.play("dash")
				
				stateMovement.wall_cling:
					$playerAnimation.play("wallCling")
					
				stateMovement.idle_ground:
					$playerAnimation.play("idle")
				
				stateMovement.moving_ground:
					$playerAnimation.play("run")
					
				stateMovement.dash:
					$playerAnimation.play("slide")
				
				stateMovement.idle_air, stateMovement.moving_air:
					$playerAnimation.play("jump")
					
				stateMovement.wall_cling:
					$playerAnimation.play("wallCling")

	
	pass

#Method used by AnimationPlayer to reset the state at the end of animation - ???
func actionState_neutral():
	currentActionState = stateAction.neutral
	pass

<<<<<<< HEAD
#Gravity handle
func gravity_handle(factor):
	velocityToAdd.y += gravity/factor
	
=======
#Check cling area
func check_clingArea(area):
	if area.get_overlapping_areas().size() > 0:
		if area.get_overlapping_areas()[0].is_in_group(groupsTerrainArea.WALL_CLING):
			currentMoveState = stateMovement.wall_cling
			currentClingSlideSpeed =  area.get_overlapping_areas()[0].slipFactor * gravity
			pass
		pass
>>>>>>> parent of 86f9f74 (Move To Action change)
	pass

#Cling Slide handle
#TODO!
func clingSlide_handle(slipFactor):
	
	print(velocity.y, " vel |", velocityToAdd.y, " velAdd |", (gravity*slipFactor)/3, " step |", gravity*slipFactor, " pivot")
	#genericRubberband_handler(velocity.y, velocityToAdd.y, 5000, gravity*slipFactor)
	
	if velocity.y > gravity*slipFactor:
		velocityToAdd.y -= (gravity*slipFactor)/3

	elif velocity.y < gravity*slipFactor:
		velocityToAdd.y  += (gravity*slipFactor)/3

	
	pass

#Check cling area

#Wall slide handle
func clingSlide_handle():
		if velocity.y > 0:
			velocityToAdd.y -= gravity/3
			if velocity.y - gravity/3 < 0:
				velocityToAdd.y = -velocity.y
		elif velocity.y < 0:
			velocityToAdd.y  += gravity/3
			if velocity.y + gravity/3 > 0:
				velocityToAdd.y = -velocity.y

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
<<<<<<< HEAD
func natural_forces_handle(moveState: int, actionState: int) -> void:
	
	#Add initial gravity
	gravity_handle(7)
	
	#Downpull force handle
	if actionState == stateAction.wall_cling:
		clingSlide_handle(currentClingSlideFactor)
=======
func natural_forces_handle(moveState):
	
	#Don't add gravity if clinging or grounded
	if moveState == stateMovement.wall_cling:
		if velocity.y != 0:
			clingSlide_handle()
		else:
			velocity.y = 0
		pass
		
	elif !is_grounded:
		velocity.y += gravity/7
>>>>>>> parent of 86f9f74 (Move To Action change)
		
	
	if moveState == stateMovement.moving_ground:
		friction_handle()

	#If correct state, check rubberband force
	
	
	pass

func _physics_process(delta):
	
	#Input handler event
	input_handle()
	
	#State handler
	state_handle()
<<<<<<< HEAD
=======
	print(currentMoveState)
>>>>>>> parent of 86f9f74 (Move To Action change)
	
	#Animation handle
	#Play correct animation according to state
	animation_handle()
	
	#Handle rubberbanding of movement
	natural_forces_handle(currentMoveState, currentActionState)

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
	
	
	pass # Replace with function body.




func _on_ClingArea_area_entered(area):
	currentActionState = stateAction.wall_cling
	currentClingSlideFactor = area.slipFactor
	
	pass # Replace with function body.


func _on_ClingArea_area_exited(area):
	currentActionState = stateAction.neutral
	currentClingSlideFactor = 0
	pass # Replace with function body.
