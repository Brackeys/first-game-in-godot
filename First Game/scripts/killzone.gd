extends Area2D

@onready var timer = $Timer
@onready var game_manager = get_tree().get_first_node_in_group("game_manager")

var victim: Node = null

	
func _on_body_entered(body):
	if not body:
		return
	if body.name != "Player":
		return
	if timer.is_stopped() == false:
		return
	if game_manager:
		game_manager.lose_life()
	print("You died!")
	Engine.time_scale = 0.4
	victim = body
	var collision_shape = body.get_node_or_null("CollisionShape2D")
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	body.set_process_input(false)
	body.set_process(false)
	body.set_physics_process(false)
	timer.start()


func _on_timer_timeout():
	Engine.time_scale = 1.0
	if game_manager:
		game_manager.respawn_player(victim)
	else:
		get_tree().reload_current_scene()
	victim = null
