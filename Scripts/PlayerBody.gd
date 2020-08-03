extends KinematicBody2D

#Velocity Vars#
var velocity = Vector2(0, 0)
var velocityToAdd = Vector2(0, 0)
var velocity_HorLimit = Vector2(0, 0)
var velocity_VerLimit = Vector2(0, 0)

#Character Variables
export var acceleration = 1
export var dashPower = 2.5

export var jumpPower = 2
export var flapPower = 1.8

var speedHorizontal = 5000
var speedVertical = 100000

#World Variables
export var frict = 0.6
export var gravity = 2.3


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

#System functions
func _ready():
	#Movement units are multiplied by 1000 to use with delta#
	acceleration *= speedHorizontal
	frict *= speedHorizontal
	dashPower *= speedHorizontal
	
	jumpPower *= gravity/1.4
	jumpPower *= -speedVertical
	
	
	flapPower *= -speedVertical
	flapPower -= gravity
	
	gravity *= speedVertical/10
	
	
	
	#Velocity initialized#
	velocity_HorLimit = Vector2(acceleration*-8,acceleration*8);
	velocity_VerLimit = Vector2(-gravity*200, gravity*3)
	velocity = Vector2(0, 0)
	
	
	#We start midair#
	currentMoveState = stateMovement.idle_air
	currentActionState = stateAction.neutral
	pass

#Custom functions
func input_handle():
	#Check state and determine calculations
	
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
		
		if Input.is_action_just_pressed("wingflap"):
				velocityToAdd.y = 0
				velocityToAdd.y += flapPower       
		
	#Regulate speed achievable via normal movement
	velocityToAdd.x = clamp(velocityToAdd.x, velocity_HorLimit.x, velocity_HorLimit.y)                                                                 
	
	#DASH 
	if Input.is_action_just_pressed("dash"):
		print("a")
		if Input.is_action_pressed("ui_left"):
			velocityToAdd.x -= dashPower
		elif Input.is_action_pressed("ui_right"):
			velocityToAdd.x += dashPower
		
	pass
	
#Checks in proccess if states should be changed
func state_handle():
	
	#If it is not changed, it stays in the air.
	if velocity.x != 0:
		currentMoveState = stateMovement.moving_air
	else:
		currentMoveState = stateMovement.idle_air
		pass
	
	#Check if colliding with any terrain
	for i in range(get_slide_count()):
		var currentCollider = get_slide_collision(i).get_collider()
		
		if currentCollider.is_in_group("ground"):
			if velocity.x == 0:
				currentMoveState = stateMovement.idle_ground
				return
				pass
			else:
				currentMoveState = stateMovement.moving_ground
				return
				pass
		elif currentCollider.is_in_group("wall"):
			currentMoveState = stateMovement.wall_cling
			return
			pass
		pass
		#If nothing returns, obviously mid-air.
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
		

	
	print(velocityToAdd)

func _physics_process(delta):
	
	#Add Gravity
	velocity.y += gravity
	
	#Input handler event
	input_handle()
	
	#State handler
	state_handle()
	
	#Handle friction via ToAdd
	friction_handle()
	
	#TODO: Clamp the velocity when added
	
	#Regulate velocity

	velocity.x += velocityToAdd.x
	velocity.y += velocityToAdd.y
	
	#Write custom function, no clamp, so you can dash.
	velocity.y = clamp(velocity.y, velocity_VerLimit.x, velocity_VerLimit.y)
	velocity.x = clamp(velocity.x, velocity_HorLimit.x, velocity_HorLimit.y)

	#Move 
	move_and_slide(velocity*delta)
	
	#Reset velToAdd variable
	velocityToAdd.x = 0
	velocityToAdd.y = 0

	
	pass
