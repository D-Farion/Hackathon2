extends CharacterBody2D

#store player, direction and speed
@export var player_reference : CharacterBody2D
@export var stats: Stats
var direction : Vector2

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
		$HurtBox.owner_stats = stats
		
func _ready() -> void:
	pass

func _on_death() -> void:
	queue_free()

#enemies move towards player
func _physics_process(delta):
	velocity = (player_reference.position - position).normalized() * stats.current_move_speed
	move_and_collide(velocity * delta)
