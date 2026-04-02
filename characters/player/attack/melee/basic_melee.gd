class_name BasicMelee
extends Weapon

@export var knockback_force: float = 200.0
@export var swing_arc: float = PI / 2.0   # 90 degree arc
@export var reach: float = 40.0           # how far from player center
@export var swing_duration: float = 0.15  # how long the sweep takes

var _swing_left: bool = true              # alternates side each swing

func _on_ready() -> void:
	pass  # no setup needed, hitboxes are spawned per swing

func _attack() -> void:
	var mouse_dir: Vector2 = (_player.get_global_mouse_position() - _player.global_position).normalized()
	var base_angle := mouse_dir.angle()
	var side := 1.0 if _swing_left else -1.0
	_swing_left = !_swing_left
	
	for i in projectile_count:
		# Start and end angles of the sweep
		var start_angle := base_angle - (swing_arc * 0.5 * side)
		var end_angle   := base_angle + (swing_arc * 0.5 * side)
		var shape := CircleShape2D.new()
		shape.radius = area
		
		var hit_log := HitLog.new()  # Putting the hitlog inside the for loop allows each swing to hit the same enemy
		var hitbox := HitBox.new(
			_player.stats,
			swing_duration + 0.05,  # lifetime slightly longer than sweep
			shape,
			hit_log
		)

		_player.add_child(hitbox)

	# Tween the hitbox position along the arc
		var tween := _player.create_tween()
		tween.tween_method(
			func(angle: float):
				if is_instance_valid(hitbox):
					hitbox.global_position = _player.global_position + Vector2.from_angle(angle) * reach,
			start_angle,
			end_angle,
			swing_duration
		)
		await get_tree().create_timer(0.1).timeout

func _on_upgrade() -> void:
	match level:
		2: area *= 1.2          # bigger hitbox
		3: cooldown *= 0.8      # faster swings
		4: reach += 15.0        # longer reach
		5: swing_arc = PI       # full 180 degree swing
