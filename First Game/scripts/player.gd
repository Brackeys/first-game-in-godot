extends CharacterBody2D


const MAX_SPEED = 300.0
const ACCEL = 900.0
const DECEL = 500.0
const TURN_DECEL = 500.0
const AIR_CONTROL = 1
const JUMP_BASE = 555.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var double_jump = 1
var double_jump_count = 1
var jump_release_force = 0
var jump_force = 0
var has_playdate := false
var has_donut := false
var is_dead := false


@onready var animated_sprite = $Violet

	
func play_lose_life_anim():

	is_dead = true
	animated_sprite.play("death")
		
# Main Player Controls	
func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Get the input direction: -1,0,1
	var direction = Input.get_axis("move_left", "move_right")

	# Handle Jump (constant ollie height)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -JUMP_BASE
		animated_sprite.play("Jump")
	 
		# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Apply movement with skate-like momentum
	var accel = ACCEL if is_on_floor() else ACCEL * AIR_CONTROL
	var decel = DECEL if is_on_floor() else DECEL * AIR_CONTROL
	var turn_decel = TURN_DECEL if is_on_floor() else TURN_DECEL * AIR_CONTROL
	if direction: 
		var target = direction * MAX_SPEED
		if sign(velocity.x) != sign(target) and abs(velocity.x) > 5.0:
			velocity.x = move_toward(velocity.x, 0, turn_decel * delta)
		else:
			velocity.x = move_toward(velocity.x, target, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, decel * delta)
	
	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("Jump")
	
	move_and_slide()
