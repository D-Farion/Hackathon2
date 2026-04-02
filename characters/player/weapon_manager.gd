class_name WeaponManager
extends Node

var _stats: Stats  # reference to the player's Stats resource

# Preload your weapon scenes here
const WEAPON_SCENES := {
	"basic_melee":   preload("res://characters/player/attack/basic_melee.gd"),
	"orbital_weapon": preload("res://characters/player/attack/orbital/orbital_weapon.tscn"),
}

var _weapons: Dictionary = {}  # { "wand": Weapon, ... }

func _ready() -> void:
	# Assumes player has a variable called `stats` holding the Stats resource
	_stats = get_parent().stats

func add_weapon(weapon_id: String) -> void:
	if _weapons.has(weapon_id):
		upgrade_weapon(weapon_id)
		return

	var scene = WEAPON_SCENES.get(weapon_id)
	if not scene:
		push_error("Unknown weapon: " + weapon_id)
		return

	var weapon: Weapon = scene.instantiate()
	add_child(weapon)
	_weapons[weapon_id] = weapon

func upgrade_weapon(weapon_id: String) -> void:
	if _weapons.has(weapon_id):
		_weapons[weapon_id].upgrade()

func has_weapon(weapon_id: String) -> bool:
	return _weapons.has(weapon_id)
