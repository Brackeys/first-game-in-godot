extends CanvasLayer

@onready var score_label = $MarginContainer/ScoreLabel
@onready var time_label = $TimeLabel
@onready var lives_label = $LivesLabel
var start_time : int


var current_score := 0
var current_time := start_time
var current_lives := 3

func _ready():
	update_score_label()
	update_time_label()
	update_lives_label()

func set_score(score := 0):
	current_score = score
	update_score_label()

func add_score(amount := 0):
	current_score += amount
	update_score_label()

#removed hardcoded time
func set_time(time := current_time):
	current_time = time
	update_time_label()

func set_lives(lives := 3):
	current_lives = max(lives, 0)
	update_lives_label()

func update_score_label():
	score_label.text = "Score: " + str(current_score)

func update_time_label():
	time_label.text = "Time: " + str(current_time)

func update_lives_label():
	lives_label.text = "Lives: " + str(current_lives)
