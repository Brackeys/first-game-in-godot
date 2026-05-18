extends Control

@onready var restart_button = $VBoxContainer/HBoxContainer/NewButton

func _ready():
	restart_button.grab_focus()
	await get_tree().process_frame
	restart_button.grab_focus()
	restart_button.pressed.connect(_on_restart_button_pressed)

func _on_restart_button_pressed():
	print("restart pressed ✅")
	get_tree().change_scene_to_file("res://scenes/UI/start_menu.tscn")
