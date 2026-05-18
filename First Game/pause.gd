extends Control

@onready var resume_button = %ResumeButton
@onready var end_button = %EndButton

func _ready():

	visible = false

	resume_button.pressed.connect(_on_resume_pressed)
	end_button.pressed.connect(_on_end_pressed)

func _input(event):

	if event.is_action_pressed("Pause"):
		print("paused ✅")
		toggle()

func toggle():

	visible = !visible
	get_tree().paused = visible

	if visible:
		await get_tree().process_frame
		resume_button.grab_focus()

func _on_resume_pressed():

	get_tree().paused = false
	visible = false

func _on_end_pressed():

	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/UI/start_menu.tscn") 
