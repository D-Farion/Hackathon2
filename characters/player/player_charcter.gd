class_name Player
extends CharacterBody2D

@export var display_name : StringName = &"player"
@export var hitbox_shape: Shape2D
@export var stats: Stats

func _ready() -> void:
	# Runs once when the node enters the scene tree
	stats.health_changed.connect(_on_health_changed)
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and not event.is_echo():
		var hit_log: HitLog = HitLog.new()
		for n in 1: #number of hitboxes attack will have 
			var hitbox = HitBox.new(stats, 0.5, hitbox_shape, hit_log)
			add_child(hitbox)
			hitbox.global_position = global_position + Vector2(40, 0)

func _physics_process(delta: float) -> void:
	# Basic 2D movement 
	var direction = Input.get_vector(&"left", &"right", &"up", &"down")
	if direction:
		velocity = direction * stats.base_move_speed
	else:
		# If no movement keys are held stops character
		velocity = Vector2(
			move_toward(velocity.x, 0, stats.base_move_speed),
			move_toward(velocity.y, 0, stats.base_move_speed)
		)
	move_and_slide()

func take_damage(amount):
	stats.health -= amount
	print(amount)

func _on_health_changed(cur_health: float, max_health: float) -> void:
	%Health.value = cur_health

func _on_self_damage_body_entered(body: Node2D) -> void:
	take_damage(body.damage)

func _on_timer_timeout() -> void:
	%Collision.set_deferred("disabled", true)
	%Collision.set_deferred("disabled", false)
