extends Area2D

signal gate_open(gate_id: int)

@export var gate_id: int = 1
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
	emit_signal("gate_open", gate_id)
	$CollisionShape2D.disabled = true