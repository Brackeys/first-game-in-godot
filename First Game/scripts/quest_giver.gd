extends Area2D

@export var intro_text := "Welcome to p:ear! We need to pickup \"Playdates\" from Panic! in downtown"

@export var reminder_text := "Time is running out get to Panic!?"

@export var completion_text := "You rock!"

var player: Node = null

var completion_pending := false

var intro_shown := false

func _ready():

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_show_intro()

func _process(_delta):

	if not player:
		return
	if Input.is_action_just_pressed("interact"):
		_show_interaction_dialogue()

func _on_body_entered(body):

	if body.name == "Player":
		player = body

func _on_body_exited(body):

	if body == player:
		player = null

func _show_intro():

	if intro_shown:
		return
	intro_shown = true
	DialogueManager.show(intro_text)

func _show_interaction_dialogue():

	if player and player.has_playdate:
		completion_pending = true
		DialogueManager.show(completion_text, _on_dialogue_done)
	else:
		completion_pending = false
		DialogueManager.show(reminder_text)

func _on_dialogue_done():

	if completion_pending:
		completion_pending = false
		GameManager.trigger_victory()
