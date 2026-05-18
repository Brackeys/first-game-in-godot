extends Control

@onready var start_button = %StartButton
@onready var credits_button = %CreditsButton
@onready var ss_button = %SlideshowButton

func _ready():
	start_button.grab_focus()
	await get_tree().process_frame
	start_button.grab_focus()
	start_button.pressed.connect(_on_start_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	ss_button.pressed.connect(_on_ss_pressed)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/UI/level1-title.tscn")

func _on_credits_pressed():
	get_tree().change_scene_to_file("res://scenes/UI/credits.tscn")


func _on_ss_pressed():
	get_tree().change_scene_to_file("res://scenes/slideshow.tscn")
