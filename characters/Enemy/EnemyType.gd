extends Resource
class_name Enemy

@export var title : String
@export var texture : Texture2D
@export var health : float
@export var damage : float
@export var scale : Vector2 = Vector2(1.0, 1.0)
@export var drops : Array[Pickups]
