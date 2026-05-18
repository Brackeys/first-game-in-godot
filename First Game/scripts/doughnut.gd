extends Area2D

@onready var game_manager = %GameManager
@onready var animation_player = $AnimationPlayer

func _on_body_entered(body):
	if body.name == "Player":
		body.has_donut = true
	game_manager.add_score(game_manager.DOUGHNUT_POINTS)
	animation_player.play("pickup")
