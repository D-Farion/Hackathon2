class_name Dash
extends Ability

@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.18
@export var invincible_during_dash: bool = true

func _on_ready() -> void:
	cooldown = 3.0

func _activate() -> void:
	# Use current movement direction, fall back to mouse direction
	var dir := Input.get_vector(&"left", &"right", &"up", &"down")
	if dir == Vector2.ZERO:
		dir = (_player.get_global_mouse_position() - _player.global_position).normalized()

	if invincible_during_dash:
		_player.can_take_damage = false

	# Override velocity for the dash duration via a tween
	var tween := _player.create_tween()
	tween.tween_method(
		func(_t: float):
			_player.velocity = dir * dash_speed
			_player.move_and_slide(),
		0.0, 1.0,
		dash_duration
	)
	await tween.finished

	if invincible_during_dash:
		_player.can_take_damage = true

func _on_upgrade() -> void:
	match level:
		2: cooldown = 2.2          # faster recharge
		3: dash_duration = 0.24    # longer dash
		4: dash_speed = 800.0      # faster dash
		5: invincible_during_dash = true  # always on from here
