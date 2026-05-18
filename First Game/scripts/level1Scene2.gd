extends Node2D

func _ready():

	await get_tree().process_frame
	var spawn = get_tree().get_first_node_in_group("spawnpoint")
	if spawn:
		GameManager.spawn_position = spawn.global_position
