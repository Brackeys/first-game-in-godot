extends MultiplayerSynchronizer

@onready var player = $".."

var input_direction 

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if get_multiplayer_authority() != multiplayer.get_unique_id():
		set_process(false)
		set_physics_process(false)
	
	input_direction = Input.get_axis("move_left", "move_right")

func _physics_process(delta):
	input_direction = Input.get_axis("move_left", "move_right")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("jump"):
		jump.rpc()

@rpc("call_local")
func jump():
	if multiplayer.is_server():
		player.do_jump = true
