extends Node

@onready var player: CharacterBody2D = $"../Player"

var score = 0
var total_coins = 0


func _ready() -> void:
	total_coins = count_level_coins()
	score = total_coins
	update_score_label()

func add_point() -> void:
	score = max(score - 1, 0)
	update_score_label()


func has_all_coins() -> bool:
	if total_coins <= 0:
		return true
	return score <= 0


func update_score_label() -> void:
	if player == null:
		return
	var score_label := player.get_node_or_null("CanvasLayer/HUD/ScoreLabel") as Label
	if score_label != null:
		score_label.text = "Signal Left: " + str(score)


func count_level_coins() -> int:
	var root := get_tree().current_scene
	if root == null:
		return 0

	var count := 0
	for node in root.find_children("*", "Area2D", true, false):
		var script := node.get_script() as Script
		if script == null:
			continue
		if script.resource_path == "res://src/objects/collectibles/extinguisher.gd":
			count += 1

	return count
