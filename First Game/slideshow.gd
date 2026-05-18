extends Control

@onready var image = $TextureRect
@onready var timer = $Timer

var images = [
	preload("res://assets/slideshow/slide1.jpg"),
	preload("res://assets/slideshow/slide2.jpg"),
	preload("res://assets/slideshow/slide3.jpg"),
	preload("res://assets/slideshow/slide4.jpg"),
	preload("res://assets/slideshow/slide5.jpg"),
	preload("res://assets/slideshow/slide6.jpg"),
	preload("res://assets/slideshow/slide7.jpg"),
	preload("res://assets/slideshow/slide8.jpg"),
	preload("res://assets/slideshow/slide9.jpg"),
	preload("res://assets/slideshow/slide10.jpg"),
	preload("res://assets/slideshow/slide11.jpg")
	
]

var index := 0

func _ready():
	image.texture = images[index]
	timer.wait_time = 2.5   # seconds per image
	timer.start()
	timer.timeout.connect(_next_image)

func _next_image():
	index += 1

	if index >= images.size():
		_end_slideshow()
		return

	image.texture = images[index]

func _end_slideshow():
	print("Slideshow finished")
	get_tree().change_scene_to_file("res://scenes/UI/start_menu.tscn")
