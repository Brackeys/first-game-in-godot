extends Node

var dialogue_ui

func _ready():

	dialogue_ui = preload("res://scenes/UI/dialogueUI.tscn").instantiate()
	get_tree().root.call_deferred("add_child", dialogue_ui)

func show(text: String, callback: Callable = Callable()):
	if dialogue_ui == null:
		await get_tree().process_frame

	dialogue_ui.show_dialogue(text)

	if callback.is_valid():
		dialogue_ui.dialogue_finished.connect(callback, CONNECT_ONE_SHOT)
