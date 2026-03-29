extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if body and body.has_method("lose_life"):
		body.lose_life()
		return

	Engine.time_scale = 0.5
	var collision_shape: CollisionShape2D = body.get_node_or_null("CollisionShape2D")
	if collision_shape:
		collision_shape.queue_free()
	timer.start()
	


func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
