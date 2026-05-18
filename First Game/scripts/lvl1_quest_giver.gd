extends Control

@onready var dialog_button = %DialogClose

func _ready():
	dialog_button.pressed.connect(_on_dialog_close_pressed)
	dialog_button.grab_focus()

func _on_dialog_close_pressed():
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")
