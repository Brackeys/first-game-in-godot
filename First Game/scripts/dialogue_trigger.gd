extends Area2D

@export var dialogue_text := "Welcome to Panic!"

@export var next_scene_path := "res://scenes/UI/panic_npc.tscn"

var triggered := false

func _ready():

	body_entered.connect(_on_body_entered)

func _on_body_entered(body):

	print("entered by:", body.name)
	if triggered:
		return
	print("checking body...")
	if body is CharacterBody2D:
		print("PLAYER DETECTED ✅")
		triggered = true
		get_tree().call_deferred("change_scene_to_file", next_scene_path)
	else:
		print("IGNORED:", body.name)
