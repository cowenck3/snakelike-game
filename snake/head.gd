extends Sprite2D


signal apple_eaten
signal game_over

@export var body_scene : PackedScene



func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("apple"):
		emit_signal("apple_eaten")
	else:
		emit_signal("game_over")
