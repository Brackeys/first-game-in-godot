extends CharacterBody2D

const SPEED = 60.0

const GRAVITY = 900.0

var direction = 1

@onready var ray_cast_right = $RayCastRight

@onready var ray_cast_left = $RayCastLeft

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	velocity.x = direction * SPEED
	move_and_slide()
