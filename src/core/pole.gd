extends Area2D

class_name Pole

enum PoleRole {
	START,
	END
}

@export var role: PoleRole = PoleRole.START
@export var cable_color: Color = Color(0.1, 0.85, 1.0, 1.0)
@export var cable_width: float = 3.0

const CONNECTION_COMPLETE_SCENE := "res://scenes/core/connection_complete.tscn"
const CONNECTION_COMPLETE_SCRIPT := preload("res://src/core/connection_complete.gd")
const TUTORIAL_SCENE := "res://scenes/levels/tutorial.tscn"
const LEVEL1_SCENE := "res://scenes/levels/level1.tscn"
const LEVEL2_SCENE := "res://scenes/levels/level2.tscn"
const LEVEL3_SCENE := "res://scenes/levels/level3.tscn"
const NEXT_LEVEL_AFTER_TUTORIAL := "res://scenes/levels/level1.tscn"
const NEXT_LEVEL_AFTER_FIRST := "res://scenes/levels/level2.tscn"
const NEXT_LEVEL_AFTER_SECOND := "res://scenes/levels/level3.tscn"
const NEXT_LEVEL_AFTER_THIRD := "res://scenes/levels/ending.tscn"

static var start_pole: Pole = null

var connected_end_pole: Pole = null
var cable_line: Line2D = null
var has_triggered_completion := false


func _ready() -> void:
	# Player body is on layer 2 in this project.
	collision_mask = 2
	body_entered.connect(_on_body_entered)

	if role == PoleRole.START:
		start_pole = self
		ensure_cable_line()


func _process(_delta: float) -> void:
	if connected_end_pole == null or cable_line == null:
		return

	# Keep the cable endpoint synced if poles move.
	cable_line.set_point_position(1, to_local(connected_end_pole.global_position))


func _on_body_entered(body: Node2D) -> void:
	if role != PoleRole.END:
		return

	if not is_player_body(body):
		return

	connect_start_to_me()


func connect_start_to_me() -> void:
	if not can_connect_now():
		print("Collect all coins before connecting the cable.")
		return

	if start_pole == null:
		push_warning("No START pole found in scene.")
		return

	start_pole.connect_to_end(self)
	trigger_level_completion()


func connect_to_end(end_pole: Pole) -> void:
	if end_pole == null:
		return

	ensure_cable_line()
	connected_end_pole = end_pole
	cable_line.visible = true
	cable_line.set_point_position(0, Vector2.ZERO)
	cable_line.set_point_position(1, to_local(end_pole.global_position))


func ensure_cable_line() -> void:
	if cable_line != null:
		return

	cable_line = Line2D.new()
	cable_line.name = "CableLine"
	cable_line.default_color = cable_color
	cable_line.width = cable_width
	cable_line.z_index = 20
	cable_line.add_point(Vector2.ZERO)
	cable_line.add_point(Vector2.ZERO)
	cable_line.visible = false
	add_child(cable_line)


func is_player_body(body: Node2D) -> bool:
	return body != null and (body.name == "Player" or body.is_in_group("player") or body is CharacterBody2D)


func can_connect_now() -> bool:
	var game_manager := find_game_manager()
	if game_manager == null:
		# If there's no manager, don't block progression.
		return true

	if game_manager.has_method("has_all_coins"):
		return game_manager.has_all_coins()

	return true


func find_game_manager() -> Node:
	var current: Node = self
	while current != null:
		var candidate := current.get_node_or_null("GameManager")
		if candidate != null:
			return candidate
		current = current.get_parent()

	return null


func trigger_level_completion() -> void:
	if has_triggered_completion:
		return
	has_triggered_completion = true

	var current_scene := get_tree().current_scene
	if current_scene == null:
		return

	var current_path := current_scene.scene_file_path
	var message := "Connection completed"
	var next_scene := ""

	match current_path:
		TUTORIAL_SCENE:
			message = "Tutorial connection completed"
			next_scene = NEXT_LEVEL_AFTER_TUTORIAL
		LEVEL1_SCENE:
			message = "First connection completed"
			next_scene = NEXT_LEVEL_AFTER_FIRST
		LEVEL2_SCENE:
			message = "Second connection completed"
			next_scene = NEXT_LEVEL_AFTER_SECOND
		LEVEL3_SCENE:
			message = "Third connection completed"
			next_scene = NEXT_LEVEL_AFTER_THIRD
		_:
			# Only run this transition flow for level progression scenes.
			return

	CONNECTION_COMPLETE_SCRIPT.pending_message = message
	CONNECTION_COMPLETE_SCRIPT.pending_next_scene = next_scene
	get_tree().change_scene_to_file(CONNECTION_COMPLETE_SCENE)
