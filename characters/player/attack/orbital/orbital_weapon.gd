class_name OrbitalWeapon
extends Weapon

@export var orbit_radius: float = 40.0
@export var orbit_speed: float = 2.0   # radians/sec
@export var orb_size: float = 12.0     # collision circle radius
@export var orb_count: int = 1

var _orb_hitboxes: Array[HitBox] = []
var _angle: float = 0.0
var _hit_log: HitLog                   # shared across all orbs — one log, no double hits

func _on_ready() -> void:
	_hit_log = HitLog.new()
	_spawn_orbs()

func _spawn_orbs() -> void:
	for i in orb_count:
		var shape := CircleShape2D.new()
		shape.radius = orb_size

		# HitBox handles: collision layers, damage call, hit deduplication
		var hitbox := HitBox.new(
			_player.stats,   # attacker_stats — reads current_attack automatically
			0.0,             # lifetime 0 = no auto-free, we manage it manually
			shape,
			_hit_log         # shared log so orbs don't stack-hit the same enemy
		)

		# Add visuals as a child of the hitbox
		var visual := _make_visual()
		hitbox.add_child(visual)

		_player.add_child(hitbox)
		_orb_hitboxes.append(hitbox)

func _physics_process(delta: float) -> void:
	_angle += orbit_speed * delta

	for i in _orb_hitboxes.size():
		var angle_offset := (TAU / _orb_hitboxes.size()) * i
		var offset := Vector2(orbit_radius, 0).rotated(_angle + angle_offset)
		_orb_hitboxes[i].global_position = _player.global_position + offset

	# Reset the hit log each attack interval so orbs can re-hit enemies
	_timer += delta
	if _timer >= cooldown:
		_timer = 0.0
		_hit_log = HitLog.new()
		for orb in _orb_hitboxes:
			orb.hit_log = _hit_log

func _make_visual() -> Node2D:
	# Replace with an actual Sprite2D or polygon — this is a placeholder circle
	var polygon := Polygon2D.new()
	var points: PackedVector2Array = []
	for i in 16:
		var a := (TAU / 16) * i
		points.append(Vector2(cos(a), sin(a)) * orb_size)
	polygon.polygon = points
	polygon.color = Color(1.0, 0.8, 0.2)
	return polygon

func _on_upgrade() -> void:
	match level:
		2: orbit_speed *= 1.2
		3: _add_orb()
		4: orbit_radius += 20.0
		5: cooldown = max(0.3, cooldown * 0.8)  # re-hits enemies faster

func _add_orb() -> void:
	orb_count += 1
	var shape := CircleShape2D.new()
	shape.radius = orb_size
	var hitbox := HitBox.new(_player.stats, 0.0, shape, _hit_log)
	hitbox.add_child(_make_visual())
	_player.add_child(hitbox)
	_orb_hitboxes.append(hitbox)
