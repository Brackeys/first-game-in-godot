extends Control

@onready var lvl1 = %Lvl1
@onready var back = %Back

func _ready():
	lvl1.pressed.connect(_on_lvl1_pressed)
	back.pressed.connect(_on_back_pressed)
	lvl1.grab_focus()
	
func _on_lvl1_pressed():
	get_tree().change_scene_to_file("res://scenes/UI/Start_animation_lvl1.tscn")


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/UI/start_menu.tscn")
