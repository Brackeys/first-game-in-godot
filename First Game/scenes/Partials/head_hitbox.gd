extends Area2D

func _ready():

	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("HEAD HIT:", body.name)
	if body.name == "Player":
		if body.velocity.y > 0:
			print("STOMPED ✅")
			# bounce player
			body.velocity.y = -300
			# kill enemy
			get_parent().queue_free()
