class_name HitBox
extends Area2D

var attacker_stats: Stats
var hitbox_lifetime: float
var shape: Shape2D
var hit_log: HitLog


func _init(_attacker_stats: Stats, _hitbox_lifetime: float, _shape: Shape2D, _hitlog: HitLog = null) -> void:
	attacker_stats = _attacker_stats
	hitbox_lifetime = _hitbox_lifetime
	shape = _shape
	hit_log = _hitlog

func _ready() -> void:
	monitorable = false
	monitoring = true
	area_entered.connect(_on_area_entered)
	
	if hitbox_lifetime > 0.0:
		get_tree().create_timer(hitbox_lifetime).timeout.connect(queue_free)
		
	if shape:
		var collision_shape = CollisionShape2D.new()
		collision_shape.shape = shape
		add_child(collision_shape)
		
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	match attacker_stats.faction:
		Stats.Faction.PLAYER:
			set_collision_mask_value(2, true)
		Stats.Faction.ENEMY:
			set_collision_mask_value(1, true)
	
	# check overlaps that already exist on spawn
	await get_tree().physics_frame
	for area in get_overlapping_areas():
		_on_area_entered(area)
	
func _on_area_entered(area: Area2D) -> void:
	if not area.has_method("receive_hit"):
		return
	
	var hurtbox_owner = area.owner  # used for hit deduplication, not for the call
	if hit_log:
		if hit_log.has_hit(hurtbox_owner):
			return
		else:
			hit_log.log_hit(hurtbox_owner)
	
	area.receive_hit(attacker_stats.current_attack)
