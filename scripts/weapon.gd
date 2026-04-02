class_name Weapon
extends Node2D

@export var damage_multiplier: float = 1.0  # rename from `damage`
@export var cooldown: float = 1.0
@export var area: float = 30.0
@export var projectile_speed: float = 300.0
@export var pierce: int = 1
@export var projectile_count: int = 1
@export var proc_chance: float = 1.0

var level: int = 1
var _timer: float = 0.0
var _player: CharacterBody2D

func _ready() -> void:
	_player = get_parent().get_parent()  # WeaponManager -> Player
	_on_ready()

func _physics_process(delta: float) -> void:
	_timer += delta
	if _timer >= cooldown:
		_timer = 0.0
		_attack()

func _on_ready() -> void:
	pass  # override in each specific weapon

func _attack() -> void:
	pass  # override in each specific weapon

func upgrade() -> void:
	level += 1
	_on_upgrade()

func _on_upgrade() -> void:
	pass  # override in each specific weapon
