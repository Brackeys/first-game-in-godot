extends Control

@export var scroll_speed := 30.0

@onready var back_button: Button = %BackButton

func _ready():
	back_button.pressed.connect(_on_back_pressed)


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/UI/start_menu.tscn")
