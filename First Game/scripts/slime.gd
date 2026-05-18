extends Node2D

const SPEED = 60
const GRAVITY = 900.0
var direction = 1

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.


func _physics_process(delta):

	# gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	# wall detection
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	# movement
	velocity.x = direction * SPEED
	move_and_slide()
