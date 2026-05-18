extends Node2D

func _ready():

	await get_tree().process_frame
	GameManager.spawn_position = $Checkpoints/SpawnPoint.global_position
	print("Spawn updated:", GameManager.spawn_position)
