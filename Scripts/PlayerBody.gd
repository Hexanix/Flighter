extends RigidBody2D

#Vars#
var velocity = Vector2(0, 0)
var velocity_HorLimit = Vector2(0, 0)

var statesMovement = ["idle_air", "idle_ground", "moving_air", "moving_ground", "dash"]    
var statesAction = ["neutral", "attack", "parry"]
var currentState

func input_handle():
	pass

func _ready():
	velocity_HorLimit = Vector2(-10,10);
	velocity = Vector2(0, 0)
	
	currentState = "idle_ground"
	pass

func _process(delta):

	if currentState == "idle_ground":
		if Input.is_action_pressed("ui_right"):
			velocity.x += 6
		elif velocity.x > 0:
			velocity.x -= 8
			
		clamp(velocity.x, 0, velocity_HorLimit.y)
				
		if Input.is_action_pressed("ui_left"):
			velocity.x -= 6
		elif velocity.x < 0:
			velocity.x += 8
			
		clamp(velocity.x, velocity_HorLimit.x, 0)
	
	linear_velocity.x = velocity.x
	print(linear_velocity.y)
	pass