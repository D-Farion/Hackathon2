extends Node2D

#player and enemy reference
@export var player : CharacterBody2D
@export var enemy : PackedScene

#how far enemies spawn
var distance : float = 400
var max_enemies = 75

@export var enemy_types : Array[Enemy]

var minute : int:
	set(value):
		minute = value
		%Minute.text = str(value)
		
var second : int:
	set(value):
		second = value
		if second >=60:
			second -=60
			minute += 1
		%Seconds.text = str(second).lpad(2, '0')
		
# spawn enemy from a ditance from player
func spawn(pos : Vector2):
	var enemy_instance = enemy.instantiate()
	
	#each minute a new enemy will spawn
	enemy_instance.type = enemy_types[min(minute, enemy_types.size()-1)]
	
	enemy_instance.position = pos
	enemy_instance.player_reference = player
	
	get_tree().current_scene.add_child(enemy_instance)
	
	#random distance from player in a circle
func get_random_position() -> Vector2:
	return player.position + distance * Vector2.RIGHT.rotated(randf_range(0, 2 *PI))
	
func amount(number : int = 1):
	var current_enemies = get_tree().get_nodes_in_group("enemies").size()
	var available_space = max_enemies - current_enemies
	
	if available_space <= 0:
		return
	
	for i in range(min(number, available_space)):
		spawn(get_random_position())

func _on_timer_timeout() -> void:
	second += 1
	var wave = second / 10   #incease wave every 10 seconds
	amount(5 + wave * 2)


func _on_pattern_timeout() -> void:
	for i in range(75):
		spawn(get_random_position())
