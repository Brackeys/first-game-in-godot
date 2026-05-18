extends Control

@onready var dialog_button: Button = $CenterContainer/VBoxContainer/DialogCloseButton

func _ready():
	dialog_button.grab_focus()

func _on_dialog_close_pressed():
	Engine.time_scale = 1.0
	get_tree().paused = false
	get_tree().call_deferred("change_scene_to_file", "res://scenes/level_1.tscn")
	
