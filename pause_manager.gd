extends Node

@onready var pause_ui = $"../PauseUI"
@onready var game_over_ui = $"../GameOverUI"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_ui.visible = false
	pause_ui.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause") and not game_over_ui.visible:
		if get_tree().paused:
			_resume_game()
		else:
			_pause_game()

func _pause_game() -> void:
	get_tree().paused = true
	pause_ui.visible = true

func _resume_game() -> void:
	pause_ui.visible = false
	get_tree().paused = false

func _on_resume_button_pressed() -> void:
	_resume_game()
