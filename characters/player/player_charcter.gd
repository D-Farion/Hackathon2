class_name Player
extends CharacterBody2D

@export var display_name : StringName = &"player"
@export var hitbox_shape: Shape2D
@export var stats: Stats
@onready var attack_timer: Timer = $AttackTimer
@onready var arrow: Sprite2D = $DirectionPointer

func _ready() -> void:
	# Runs once when the node enters the scene tree
	stats.health_changed.connect(_on_health_changed)
	stats.changed.connect(_on_stats_changed)
	attack_timer.wait_time = 1.0 / stats.base_attack_speed
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	attack_timer.start()

func _process(delta: float) -> void:
	var mouse_dir = (get_global_mouse_position() - global_position).normalized()
	print(mouse_dir.angle())
	arrow.rotation = mouse_dir.angle()
	arrow.position = mouse_dir * 20

func _on_attack_timer_timeout() -> void:
	var mouse_dir: Vector2 = (get_global_mouse_position() - global_position).normalized()
	var hit_log: HitLog = HitLog.new()
	var hitbox = HitBox.new(stats, 0.5, hitbox_shape.duplicate(), hit_log)
	add_child(hitbox)
	hitbox.global_position = global_position + mouse_dir * 40

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
	%Health.value = cur_health

func _on_self_damage_body_entered(body: Node2D) -> void:
	take_damage(body.stats.current_attack)

func _on_timer_timeout() -> void:
	%Collision.set_deferred("disabled", true)
	await get_tree().process_frame
	%Collision.set_deferred("disabled", false)
