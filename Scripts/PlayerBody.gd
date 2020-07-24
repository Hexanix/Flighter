extends KinematicBody2D

#Velocity Vars#
var velocity = Vector2(0, 0)
var velocity_HorLimit = Vector2(0, 0)
var velocity_VerLimit = Vector2(0, 0)

export var acceleration = 4
export var jumpPower = 0.7
export var flapPower = 0.2
export var frict = 2
export var gravity = 20


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
	parry
}


var currentMoveState
var currentActionState

#Custom functions

func input_handle():
	
	#Check state and determine calculations
	
	if currentMoveState == stateMovement.idle_ground:
		if Input.is_action_pressed("ui_right"):
			velocity.x += acceleration
		elif velocity.x > 0:
			velocity.x -= frict
			velocity.x = clamp(velocity.x, 0, velocity_HorLimit.y)
				
		if Input.is_action_pressed("ui_left"):
			velocity.x -= acceleration
		elif velocity.x < 0:
			velocity.x += frict
			velocity.x = clamp(velocity.x, velocity_HorLimit.x, 0)
		
		if Input.is_action_just_pressed("wingflap"):
			if currentMoveState == stateMovement.idle_ground:
				velocity.y += jumpPower
				currentMoveState = stateMovement.idle_air
				print(velocity.y)
	#			
	if currentMoveState == stateMovement.idle_air:
		
		if Input.is_action_pressed("ui_right"):
			velocity.x += acceleration
		elif velocity.x > 0:
			velocity.x -= frict
			velocity.x = clamp(velocity.x, 0, velocity_HorLimit.y)
				
		if Input.is_action_pressed("ui_left"):
			velocity.x -= acceleration
		elif velocity.x < 0:
			velocity.x += frict
			velocity.x = clamp(velocity.x, velocity_HorLimit.x, 0)
		
		if Input.is_action_just_pressed("wingflap"):
			if currentMoveState == stateMovement.idle_ground:
				velocity.y += flapPower
				print(velocity.y)
	
		
	pass
	
#Checks in proccess if states should be changed
func state_handle():
	
	
	pass

#System functions

func _ready():
	#Movement units are multiplied by 1000 to use with delta#
	acceleration *= 1000
	frict *= 1000
	jumpPower *= -10000*gravity
	gravity *= 10000
	
	
	#Velocity initialized#
	velocity_HorLimit = Vector2(acceleration*-8,acceleration*8);
	velocity_VerLimit = Vector2(-gravity*20, gravity*3)
	velocity = Vector2(0, 0)
	
	#We start midair#
	currentMoveState = stateMovement.idle_air
	currentActionState = stateAction.neutral
	pass

func _process(delta):
	#Input handler event
	input_handle()
	pass
	
func _physics_process(delta):
	
	velocity.y += gravity
	
	#Placeholder State management
	
	currentMoveState = stateMovement.idle_air
	for i in range(get_slide_count()):
		var currentCollider = get_slide_collision(i).get_collider()
		
		if currentCollider.is_in_group("ground"):
			currentMoveState = stateMovement.idle_ground
			velocity.y = 0
			break
			pass 
		pass
	
	velocity.y = clamp(velocity.y, velocity_VerLimit.x, velocity_VerLimit.y)
	velocity.x = clamp(velocity.x, velocity_HorLimit.x, velocity_HorLimit.y)

	print(currentMoveState)
	move_and_slide(velocity*delta)
	
	pass