extends CharacterBody2D

#store player, direction and speed
@export var player_reference : CharacterBody2D
@export var stats: Stats
var direction : Vector2
var knockback : Vector2


var drop = preload("res://Scenes/pickups.tscn")

var type : Enemy:
	set(value):
		type = value
		$Sprite2D.texture = value.texture
		$Sprite2D.scale = value.scale
		stats = stats.duplicate()
		stats.base_attack = value.damage
		stats.base_max_health = value.health
		stats.setup_stats()
		stats.health_depleted.connect(_on_death)
		stats.health_changed.connect(_on_health_changed)
		$HurtBox.owner_stats = stats
		
func _ready() -> void:
	pass

func _on_death() -> void:
	drop_item()
	queue_free()

func _on_health_changed(cur_health: float, max_health: float) -> void:
	flash_red()

func flash_red() -> void:
	var hit_tween = create_tween()
	hit_tween.tween_property($Sprite2D, "modulate", Color(1, 0, 0, 1), 0.2)
	hit_tween.tween_property($Sprite2D, "modulate", Color(1, 1, 1, 1), 0.05)

#enemies move towards player
func _physics_process(delta):
	velocity = (player_reference.position - position).normalized() * stats.current_move_speed * 0.4
	knockback = knockback.move_toward(Vector2.ZERO, 100 * delta)
	velocity += knockback
	
	var collider = move_and_collide(velocity * delta)
	if collider:
		collider.get_collider().knockback = (collider.get_collider().global_position - global_position).normalized() * 50
		
		
		
		
		
func drop_item():
	
	if type.drops.size() == 0:
		return
	var item = type.drops.pick_random()
	
	var item_to_drop = drop.instantiate()
	
	item_to_drop.type = item
	item_to_drop.position = position
	item_to_drop.player_reference = player_reference
	
	get_tree().current_scene.call_deferred("add_child", item_to_drop)
