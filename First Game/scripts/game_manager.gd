extends Node

@onready var score_board = get_node_or_null("%ScoreBoard")
@onready var score_label = score_board.get_node_or_null("MarginContainer/ScoreLabel") if score_board else null
@onready var time_label = score_board.get_node_or_null("TimeLabel") if score_board else null
@onready var lives_label = score_board.get_node_or_null("LivesLabel") if score_board else null
@onready var game_over_label = score_board.get_node_or_null("GameOverLabel") if score_board else null
@onready var victory_label = score_board.get_node_or_null("VictoryLabel") if score_board else null
@onready var player = get_node_or_null("%Player")

const CAN_POINTS = 10
const TRICK_POINTS = 20
const DOUGHNUT_POINTS = 50

@export var max_lives := 3
@export var start_time := 500
@export var countdown_enabled := true
@export var is_dead := false

var base_score := 0
var current_score := 0
var current_time := start_time
var current_lives := 3
var spawn_position = Vector2.ZERO
var game_over := false
var victory := false
var countdown_timer: Timer = null
var light_switches_activated := 0
var activated_switches := {}
var quit_timer = 0.0

func _ready():
	Engine.time_scale = 1.0
	print("GameManager loaded ✅")
	add_to_group("game_manager")
	await get_tree().process_frame
	if player:
		spawn_position = player.global_position
	current_lives = max_lives
	print("Spawn position:", spawn_position)
	current_time = start_time
	print("Start Time:", start_time)
	print("Current Time:", current_time)
	update_score_label()
	update_time_label()
	update_lives_label()
	hide_game_over()
	hide_victory()
	if countdown_enabled:
		start_countdown()
			

func set_score(score := 0):
	base_score = score
	current_score = score
	update_score_label()

func add_score(amount := 0):
	base_score += amount
	current_score = base_score
	update_score_label()

func add_trick_score():
	add_score(TRICK_POINTS)

func register_light_switch(switch_id: int):
	if activated_switches.has(switch_id):
		return
	activated_switches[switch_id] = true
	light_switches_activated += 1

func _get_score_multiplier(include_time := false) -> float:
	var multiplier := 1.0
	if player and player.has_donut:
		multiplier *= 1.5
	if light_switches_activated > 0:
		multiplier *= pow(1.5, light_switches_activated)
	if include_time:
		multiplier *= max(current_time, 0)
	return multiplier

func finalize_score():
	var multiplier = _get_score_multiplier(true)
	current_score = int(round(base_score * multiplier))
	update_score_label()

#time is hardcoded - changing to variable
func set_time(time := start_time):
	current_time = time
	update_time_label()
	if current_time <= 0:
		trigger_game_over()
		print("current time game over")

func lose_life():
	is_dead = true
	if game_over:
		return
	current_lives = max(current_lives - 1, 0)
	update_lives_label()
	if current_lives <= 0:
		trigger_game_over()
		print("lives game over")

func respawn_player(victim: Node):

	if victim == null:
		print("No victim")
		return

	print("Respawning player ✅")

	Engine.time_scale = 1.0

	victim.global_position = spawn_position

	# re-enable player
	victim.set_process(true)
	victim.set_physics_process(true)
	victim.set_process_input(true)
	victim.process_mode = Node.PROCESS_MODE_INHERIT

	# re-enable collisions
	var collision_shape = victim.get_node_or_null("CollisionShape2D")

	if collision_shape:
		collision_shape.set_deferred("disabled", false)

	# reset velocity
	if victim is CharacterBody2D:
		victim.velocity = Vector2.ZERO

func set_spawn_position(position: Vector2):
	spawn_position = position

func start_countdown():
	if countdown_timer:
		return
	countdown_timer = Timer.new()
	countdown_timer.wait_time = 1.0
	countdown_timer.one_shot = false
	add_child(countdown_timer)
	countdown_timer.timeout.connect(_on_countdown_timeout)
	countdown_timer.start()

func _on_countdown_timeout():

	current_time -= 1
	update_time_label()
	if current_time <= 0:
		trigger_game_over()

func update_score_label():
	if score_label:
		score_label.text = "Score: " + str(current_score)

func update_time_label():
	if time_label:
		time_label.text = "Time: " + str(current_time)

func update_lives_label():
	if lives_label:
		lives_label.text = "Lives: " + str(current_lives)

func trigger_game_over():
	game_over = true
	get_tree().paused = true
	print("GAME OVER ⛔")
	show_game_over()
	if player:
		player.set_physics_process(false)

func trigger_victory():
	if victory:
		return
	victory = true
	if countdown_timer:
		countdown_timer.stop()
	hide_game_over()
	finalize_score()
	show_victory()
	if player:
		player.set_physics_process(false)

func show_game_over():
	get_tree().paused = false
	get_tree().call_deferred("change_scene_to_file", "res://scenes/UI/game_over.tscn")

func hide_game_over():
	if game_over_label:
		game_over_label.visible = false

func show_victory():
	if victory_label:
		victory_label.visible = true

func hide_victory():
	if victory_label:
		victory_label.visible = false
		
func reset_game():

	game_over = false
	current_time = start_time
	current_lives = max_lives
	get_tree().paused = false
	

func _process(delta):

	if Input.is_action_pressed("ui_cancel"):
		quit_timer += delta
		if quit_timer > 3.0:
			get_tree().quit()
	else:
		quit_timer = 0.0
	if Input.is_action_pressed("ui_left") \
	and Input.is_action_pressed("ui_right") \
	and Input.is_action_pressed("Pause") \
	and Input.is_action_pressed("ui_select"):
		get_tree().quit()
