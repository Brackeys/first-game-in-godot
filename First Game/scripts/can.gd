extends Area2D

@onready var game_manager = %GameManager
@onready var animation_player = $AnimationPlayer

func _on_body_entered(_body):
	game_manager.add_score(game_manager.CAN_POINTS)
	animation_player.play("pickup")
	print("CAN TOUCHED:", _body.name)
