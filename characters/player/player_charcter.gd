class_name Player
extends CharacterBody2D

@export var display_name : StringName = &"player"

## The base movement speed of the charcter
@export var speed : float = 100.0

func _physics_process(delta: float) -> void:
	# Basic 2D movement 
	var direction = Input.get_vector(&"left", &"right", &"up", &"down")
	
	if direction:
		velocity = direction * speed
	else:
		# If no movement keys are held stops character
		velocity = Vector2(
			move_toward(velocity.x, 0, speed),
			move_toward(velocity.y, 0, speed)
		)
	
	
	move_and_slide()
