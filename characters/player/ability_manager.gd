class_name AbilityManager
extends Node

# Map ability IDs to their scenes
const ABILITY_SCENES := {
	"dash": preload("res://characters/player/ability/dash/dash.tscn"),
}

# Map ability IDs to the input action that triggers them
const ABILITY_INPUTS := {
	"dash": &"dash",  # define this in Project > Input Map
}

var _stats: Stats
var _abilities: Dictionary = {}  # { "dash": DashAbility, ... }

func _ready() -> void:
	_stats = get_parent().stats

func _unhandled_input(event: InputEvent) -> void:
	for ability_id in _abilities:
		var action = ABILITY_INPUTS.get(ability_id)
		if action and event.is_action_pressed(action):
			_abilities[ability_id].try_activate()

func add_ability(ability_id: String) -> void:
	if _abilities.has(ability_id):
		upgrade_ability(ability_id)
		return

	var scene = ABILITY_SCENES.get(ability_id)
	if not scene:
		push_error("Unknown ability: " + ability_id)
		return

	var ability: Ability = scene.instantiate()
	add_child(ability)
	_abilities[ability_id] = ability

func upgrade_ability(ability_id: String) -> void:
	if _abilities.has(ability_id):
		_abilities[ability_id].upgrade()

func has_ability(ability_id: String) -> bool:
	return _abilities.has(ability_id)
