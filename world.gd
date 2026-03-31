extends Node2D

@onready var player = $PlayerCharcter
@onready var game_over_ui = $GameOverUI
@onready var pause_ui = $PauseUI

func _ready() -> void:
	game_over_ui.visible = false
	pause_ui.visible = false
	game_over_ui.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	player.stats.health_depleted.connect(_on_player_died)

func _on_player_died() -> void:
	pause_ui.visible = false
	get_tree().paused = true
	game_over_ui.visible = true

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
