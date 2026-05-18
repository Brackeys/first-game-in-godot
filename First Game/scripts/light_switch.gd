extends Area2D

signal switched_on(switch_id: int)

@export var switch_id: int = 1
@onready var game_manager = get_node_or_null("%GameManager")
var activated := false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if activated:
		return

	if body.name == "Player" and Input.is_action_pressed("interact"):
		activate()

func activate():
	activated = true
	if game_manager:
		game_manager.register_light_switch(switch_id)
	emit_signal("switched_on", switch_id)
	$CollisionShape2D.disabled = true
