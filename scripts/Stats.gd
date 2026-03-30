extends Resource
class_name Stats


enum Faction {
	PLAYER,
	ENEMY,
}
enum BuffableStats {
	MAX_HEALTH,
	DEFENSE,
	ATTACK,
	
}

const STAT_CRUVES: Dictionary[BuffableStats, Curve] = {
	BuffableStats.MAX_HEALTH: preload("uid://b05x0hlhwnm1q"),
	BuffableStats.DEFENSE: preload("uid://d56vuccj2ma8"),
	BuffableStats.ATTACK: preload("uid://bn3snehmdidma"),
}

const BASE_LEVEL_XP: float = 100.0

signal health_depleted
signal health_changed(cur_health: int, max_health: int)

@export var base_max_health: float = 100.0
@export var base_health_regen: float = 1.0
@export var base_defense: float = 10.0
@export var base_attack: float = 10.0
@export var base_attack_speed: float = 1.0
@export var base_move_speed: float = 100.0
@export var base_crit_rate: float = 0.0
@export var base_crit_damage: float = 2.0
@export var faction: Faction = Faction.PLAYER

@export var experience: int = 0: set = _on_exp_set

var level: int:
	#basic formula for exponentially needing more experience
	get(): return floor(max(1.0, sqrt(experience / BASE_LEVEL_XP) + 0.5))
var current_attack: float = 10.0
var current_max_health: float = 100.0
var current_defense: float = 10.0

var health: float = 0.0: set = _on_health_set

var stat_buffs: Array[StatBuff]

func _init() -> void:
	#Weird quirk that if unique values on export variables set after init. 
	#So we have to wait till after the init function to setup unique stats.
	setup_stats.call_deferred()

func setup_stats() -> void:
	recalulate_stats()
	health = current_max_health

func add_buff(buff: StatBuff)-> void:
	#can optimize for multiple buffs in 1 frame
	stat_buffs.append(buff)
	recalulate_stats.call_deferred()

func remove_buff(buff: StatBuff)-> void:
	stat_buffs.erase(buff)
	recalulate_stats.call_deferred()

func recalulate_stats()-> void:
	var stat_multipliers: Dictionary = {} # amount to multiply included stats by
	var stat_addends: Dictionary = {} #amount to add to included stats
	for buff in stat_buffs:
		var stat_name: String = BuffableStats.keys()[buff.stat].to_lower()
		match buff.buff_type:
			StatBuff.BuffType.ADD:
				if not stat_addends.has(stat_name):
					stat_addends[stat_name] = 0.0
				stat_addends[stat_name] += buff.buff_amount
				
			StatBuff.BuffType.MULTIPLY:
				if not stat_multipliers.has(stat_name):
					stat_multipliers[stat_name] = 1.0
				stat_multipliers[stat_name] *= buff.buff_amount
				# With how this is implemented to get a 10% buff you have to make the buff 1.1, 10% debuff 0.9
				# This also makes multiplicative stats scale exponentially
				# If want non exponentially change buffs to be 0.X and debuffs to -0.X, and change *= to +=
				
				# Makes sure no negative multiplicative buffs, for non exponentially remove this
				if stat_multipliers[stat_name] < 0.0:
					stat_multipliers[stat_name] = 0.0
	
	
	
	var stat_sample_pos: float = float(level) / 100.0 - 0.01
	current_max_health = base_max_health * STAT_CRUVES[BuffableStats.MAX_HEALTH].sample(stat_sample_pos)
	current_defense = base_defense * STAT_CRUVES[BuffableStats.DEFENSE].sample(stat_sample_pos)
	current_attack = base_attack * STAT_CRUVES[BuffableStats.ATTACK].sample(stat_sample_pos)
	
	for stat_name in stat_addends:
		var cur_property_name: String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) + stat_addends[stat_name])
		
	for stat_name in stat_multipliers:
		var cur_property_name: String = str("current_" + stat_name)
		set(cur_property_name, get(cur_property_name) * stat_multipliers[stat_name])
	

func _on_health_set(new_value: int) -> void:
	health = clampf(new_value, 0, current_max_health)
	health_changed.emit(health, current_max_health)
	#makes sure that health dosen't go below 0 or above our max health
	if health <= 0:
		health_depleted.emit()

func _on_exp_set(new_value: int) -> void:
	var old_level: int = level
	experience = new_value

	if not old_level== level:
		recalulate_stats()
