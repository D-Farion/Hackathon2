class_name Player
extends CharacterBody2D

@export var display_name : StringName = &"player"
@export var hitbox_shape: Shape2D
@export var stats: Stats
@export var starting_weapons: Array[String] = ["basic_melee"]

@onready var attack_timer: Timer = $AttackTimer
@onready var arrow: Sprite2D = $DirectionPointer
@onready var weapon_manager: WeaponManager = $WeaponManager

func _ready() -> void:
	stats = stats.duplicate(true) as Stats
	stats.setup_stats()

	# Runs once when the node enters the scene tree
	stats.health_changed.connect(_on_health_changed)
	stats.changed.connect(_on_stats_changed)

	%Health.max_value = stats.current_max_health
	%Health.value = stats.health

	# Give starting weapons after stats are ready
	for weapon_id in starting_weapons:
		weapon_manager.add_weapon(weapon_id)

func _process(delta: float) -> void:
	#creates an arrow in the direction mouse is pointing
	var mouse_dir = (get_global_mouse_position() - global_position).normalized()
	arrow.rotation = mouse_dir.angle()
	arrow.offset = Vector2(80, 0)  # pushes the sprite along its own forward axis
	arrow.position = Vector2.ZERO  # keep it at player center

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

func _on_stats_changed() -> void:
	attack_timer.wait_time = 1.0 / stats.base_attack_speed

func _on_health_changed(cur_health: float, max_health: float) -> void:
	%Health.max_value = max_health
	%Health.value = cur_health

func _on_self_damage_body_entered(body: Node2D) -> void:
	take_damage(body.stats.current_attack)

func _on_timer_timeout() -> void:
	%Collision.set_deferred("disabled", true)
	await get_tree().process_frame
	%Collision.set_deferred("disabled", false)
