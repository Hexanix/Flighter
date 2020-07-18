extends Area2D

export var acceleration = 10
export var friction = 5
export var maxSpeed = 200
var speedHor
var statesMovement = ["idle_air", "idle_ground", "moving_air", "moving_ground", "dash"]    
var statesAction = ["neutral", "attack", "parry"]
var currentState


func _ready():
	speedHor = 0;
	currentState = "idle"
	
	pass

func _process(delta):
	
	if currentState == "idle":
		if Input.is_action_pressed("ui_left"):
			speedHor = speedHor - acceleration
			speedHor = clamp(speedHor, maxSpeed*-1, 0)
		elif speedHor < 0:
			speedHor += friction
			if speedHor > 0:
				speedHor = 0
			
		if Input.is_action_pressed("ui_right"):
			speedHor = speedHor + acceleration
			speedHor = clamp(abs(speedHor), 0, maxSpeed)
		elif speedHor > 0:
			speedHor -= friction
			if speedHor < 0:
				speedHor = 0
	
	position.x += speedHor*delta
	position.x = clamp(position.x, 0, get_viewport_rect().size.x)
		
