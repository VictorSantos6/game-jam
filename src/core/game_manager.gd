extends Node

@onready var player: CharacterBody2D = $"../Player"

var score = 0
var total_coins = 0

const SIGNAL_NO := preload("res://assets/textures/signal/no signal.png")
const SIGNAL_LOW := preload("res://assets/textures/signal/low signal.png")
const SIGNAL_MID := preload("res://assets/textures/signal/mid signal.png")
const SIGNAL_FULL := preload("res://assets/textures/signal/full signal.png")


func _ready() -> void:
	total_coins = count_level_coins()
	score = total_coins
	update_score_label()
	
	# Set initial texture before updating
	if player != null:
		var indicator := player.get_node_or_null("CanvasLayer/HUD/SignalIndicator") as TextureRect
		if indicator != null:
			indicator.texture = SIGNAL_NO
	
	update_signal_indicator()

func add_point() -> void:
	score = max(score - 1, 0)
	update_score_label()
	update_signal_indicator()


func has_all_coins() -> bool:
	if total_coins <= 0:
		return true
	return score <= 0


func update_score_label() -> void:
	if player == null:
		return
	var score_label := player.get_node_or_null("CanvasLayer/HUD/ScoreLabel") as Label
	if score_label != null:
		score_label.text = "SIGNAL LEFT: " + str(score)


func update_signal_indicator() -> void:
	if player == null:
		return
	var indicator := player.get_node_or_null("CanvasLayer/HUD/SignalIndicator") as TextureRect
	if indicator == null:
		return
	
	# Calculate percentage of signals collected (0.0 to 1.0)
	var collected: int = total_coins - score
	var percentage: float = 0.0
	if total_coins > 0:
		percentage = float(collected) / float(total_coins)
	
	# Map to signal texture
	if score <= 0:  # All signals collected
		indicator.texture = SIGNAL_FULL
	elif percentage >= 0.60:
		indicator.texture = SIGNAL_MID
	elif percentage >= 0.30:
		indicator.texture = SIGNAL_LOW
	else:
		indicator.texture = SIGNAL_NO


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
