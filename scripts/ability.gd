class_name Ability
extends Node

@export var cooldown: float = 3.0

var _player: Player
var _stats: Stats
var _on_cooldown: bool = false

func _ready() -> void:
	_player = get_parent().get_parent() as Player
	_stats = _player.stats
	_on_ready()

func _on_ready() -> void:
	pass

# Called by AbilityManager on the mapped input
func try_activate() -> void:
	if _on_cooldown:
		return
	_activate()
	_start_cooldown()

func _activate() -> void:
	pass  # override in subclasses

func _start_cooldown() -> void:
	_on_cooldown = true
	await get_tree().create_timer(cooldown).timeout
	_on_cooldown = false

func upgrade() -> void:
	level += 1
	_on_upgrade()

func _on_upgrade() -> void:
	pass

var level: int = 1
