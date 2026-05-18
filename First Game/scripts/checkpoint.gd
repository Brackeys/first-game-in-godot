extends Area2D

@onready var game_manager = get_tree().get_first_node_in_group("game_manager")

func _on_body_entered(body):
	if not body:
		return
	if body.name != "Player":
		return
	if game_manager:
		GameManager.spawn_position = $"../SpawnPoint".global_position
