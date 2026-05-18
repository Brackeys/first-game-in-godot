extends Control

@onready var lvl1play_button = %Lvl1play
@onready var back_button = %BackButton

func _ready():
	lvl1play_button.pressed.connect(_on_lvl1play_pressed)
	back_button.pressed.connect(_on_back_pressed)
	lvl1play_button.grab_focus()

func _on_lvl1play_pressed():
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/UI/start_menu.tscn")
