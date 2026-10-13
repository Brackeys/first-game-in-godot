extends SceneTree

# Mide la longitud visible de la estela al correr (130 px/s) en tiempo real.
var elapsed := 0.0
var player
var timer := 0.0
const INTERVAL := 0.04


func _initialize():
	var bg := ColorRect.new()
	bg.color = Color(0.25, 0.05, 0.05)
	bg.size = Vector2(500, 300)
	root.add_child(bg)

	player = load("res://scenes/player.tscn").instantiate()
	player.global_position = Vector2(200, 150)
	root.add_child(player)
	player.process_mode = Node.PROCESS_MODE_DISABLED


func _process(delta):
	if player == null:
		return false
	elapsed += delta
	player.global_position.x += 130.0 * delta
	player.animated_sprite.animation = "run"
	timer -= delta
	if timer <= 0.0:
		player._spawn_afterimage()
		timer = INTERVAL
	if elapsed >= 0.6:
		var img := root.get_texture().get_image()
		var min_x := 9999
		var total := 0
		for y in range(0, 300):
			for x in range(0, 500):
				var c := img.get_pixel(x, y)
				if absf(c.r - 0.25) > 0.06 or absf(c.g - 0.05) > 0.06 or absf(c.b - 0.05) > 0.06:
					min_x = mini(min_x, x)
					total += 1
		print("[TEST] player=", player.global_position, " visible=", player.visible, " total_nonbg=", total, " min_x=", min_x)
		return true
	return false
