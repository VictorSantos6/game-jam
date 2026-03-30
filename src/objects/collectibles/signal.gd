extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var game_manager: Node = find_game_manager()

func _on_body_entered(_body: Node2D) -> void:
	if game_manager != null and game_manager.has_method("add_point"):
		game_manager.add_point()
	animation_player.play("pickup")


func find_game_manager() -> Node:
	var current: Node = self
	while current != null:
		var candidate := current.get_node_or_null("GameManager")
		if candidate != null:
			return candidate
		current = current.get_parent()

	return null
