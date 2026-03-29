extends Area2D

const TUTORIAL_SCENE_PATH := "res://scenes/levels/tutorial.tscn"


func _on_body_entered(_body: Node2D) -> void:
	if not body_can_pickup(_body):
		return

	set_deferred("monitoring", false)
	get_tree().change_scene_to_file(TUTORIAL_SCENE_PATH)


func body_can_pickup(body: Node2D) -> bool:
	return body != null and body is CharacterBody2D
