extends SceneTree

# Test de RENDER real: cuenta píxeles no-fondo donde deberían estar los fantasmas.
var frames := 0
var player
var positions := [Vector2(120, 150), Vector2(180, 150), Vector2(240, 150)]


func _initialize():
	var bg := ColorRect.new()
	bg.color = Color(0.25, 0.05, 0.05)
	bg.size = Vector2(400, 300)
	root.add_child(bg)

	player = load("res://scenes/player.tscn").instantiate()
	root.add_child(player)


func _count_nonbg(img: Image, center: Vector2) -> int:
	var n := 0
	for y in range(int(center.y) - 18, int(center.y) + 18):
		for x in range(int(center.x) - 18, int(center.x) + 18):
			var c := img.get_pixel(x, y)
			if absf(c.r - 0.25) > 0.06 or absf(c.g - 0.05) > 0.06 or absf(c.b - 0.05) > 0.06:
				n += 1
	return n


func _process(_delta):
	frames += 1
	if frames >= 3 and frames <= 5:
		player.global_position = positions[frames - 3]
		player._spawn_afterimage()
	if frames == 8:
		var img := root.get_texture().get_image()
		img.save_png("res://shot.png")
		for i in 3:
			var c: Vector2 = positions[i] + Vector2(0, -12)
			print("[TEST] pos", i, " (x=", int(c.x), ") nonbg=", _count_nonbg(img, c))
		print("[TEST] OK")
		return true
	return false
