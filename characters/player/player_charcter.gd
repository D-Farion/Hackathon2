class_name Player
extends CharacterBody2D

@export var display_name : StringName = &"player"
@export var hitbox_shape: Shape2D
@export var stats: Stats
@export var starting_weapons: Array[String] = ["basic_melee"]
@export var invincible_time: float = 0.4

@onready var attack_timer: Timer = $AttackTimer
@onready var arrow: Sprite2D = $DirectionPointer
@onready var weapon_manager: WeaponManager = $WeaponManager
var can_take_damage: bool = true
var touching_enemy: Node2D = null

var XP : int = 0:
	set(value):
		XP = value
		%XP.value = value
var total_XP : int = 0
var level : int = 1:
	set(value):
		level = value
		%Level.text = "LV " + str(value)
		
		if level >= 3:
			%XP.max_value = 20
		elif level >= 7:
			%XP.max_value = 40

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
	print(get_children())

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
	check_XP()
	
func take_damage(amount: float, ignore_invincible: bool = false) -> void:
	if !can_take_damage and !ignore_invincible:
		return
	stats.health -= amount
	print(amount)
	
	start_iframes()

#creates i-frames, we can test different invincible times
func start_iframes() -> void:
	can_take_damage = false
	
	#changes opacity to show when damage is taken
	var invincible_tween = create_tween()
	invincible_tween.tween_property($PlayerSprite, "modulate", Color(1, 1, 1, 0.1), invincible_time / 4.0)
	invincible_tween.tween_property($PlayerSprite, "modulate", Color(1, 1, 1, 1), invincible_time / 4.0)
	invincible_tween.tween_property($PlayerSprite, "modulate", Color(1, 1, 1, 0.1), invincible_time / 4.0)
	invincible_tween.tween_property($PlayerSprite, "modulate", Color(1, 1, 1, 1), invincible_time / 4.0)

	
	await get_tree().create_timer(invincible_time).timeout
	can_take_damage = true

func _on_stats_changed() -> void: 
	attack_timer.wait_time = 1.0 / stats.base_attack_speed

func _on_health_changed(cur_health: float, max_health: float) -> void:
	%Health.max_value = max_health
	%Health.value = cur_health

func _on_self_damage_body_entered(body: Node2D) -> void:
	touching_enemy = body
	take_damage(body.stats.current_attack)
	$Timer.start()

#this was needed so that i-frames weren't permanent
func _on_self_damage_body_exited(body: Node2D) -> void:
	if body == touching_enemy:
		touching_enemy = null
		$Timer.stop()

func _on_timer_timeout() -> void:
	%Collision.set_deferred("disabled", true)
	await get_tree().process_frame
	%Collision.set_deferred("disabled", false)
	
	
func gain_XP(amount):
	XP += amount
	total_XP =+ amount
	
	
func check_XP():
	if XP > %XP.max_value:
		XP -= %XP.max_value
		level += 1


func _on_magnet_area_entered(area: Area2D) -> void:
	if area.has_method("follow"):
		area.follow(self)
