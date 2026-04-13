extends TextureButton


@export var weapon : Weapon:
	set(value):
		weapon = value
		texture_normal = value.texture
		$Label.text = "LVL " + str(weapon.level + 1)
		


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and weapon:
		print(weapon.title)
		get_parent().close_option()
