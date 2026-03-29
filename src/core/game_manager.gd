extends Node

@onready var player: CharacterBody2D = $"../Player"

var score = 0

func add_point():
	score += 1
	var score_label = player.get_node("CanvasLayer/HUD/ScoreLabel")
	score_label.text = str(score) + " coins!"
