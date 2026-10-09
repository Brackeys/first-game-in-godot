extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const DASH_SPEED = 400.0
const DASH_DURATION = 0.2
const MAX_JUMPS = 2
const MAX_AIR_DASHES = 1
const CROUCH_SCALE = Vector2(1.2, 0.6)   
const NORMAL_SCALE = Vector2(1.0, 1.0)
const SQUASH_SPEED = 50.0                # velocidad de la transición
const SPRITE_HALF_HEIGHT = 8.0           # la mitad de la altura de tu sprite en píxeles

var is_crouching = false
var base_sprite_y = 0.0

var jump_count = 0
var air_dash_count = 0
var is_dashing = false
var dash_timer = 0.0
var dash_dir = Vector2.RIGHT

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D


func _ready():
	# Guardamos la posición original del sprite para no desplazarlo
	base_sprite_y = animated_sprite.position.y


func _physics_process(delta):
	# Temporizador del dash
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			# Al terminar, frenamos el impulso vertical hacia arriba
			# para que el dash diagonal/vertical no te catapulte
			if velocity.y < 0:
				velocity.y *= 0.5

	# Gravedad (no se aplica durante el dash)
	if not is_on_floor() and not is_dashing:
		velocity.y += gravity * delta

	# Resetear contadores al tocar el suelo
	if is_on_floor() and not is_dashing:
		jump_count = 0
		air_dash_count = 0
	elif not is_on_floor() and jump_count == 0:
		# Si caes de una plataforma sin saltar, pierdes el primer salto
		jump_count = 1

	# Salto y doble salto
	if Input.is_action_just_pressed("jump") and not is_dashing:
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			jump_count = 1
		elif jump_count < MAX_JUMPS:
			velocity.y = JUMP_VELOCITY
			jump_count += 1

	# Entrada
	var direction = Input.get_axis("move_left", "move_right")
	var input_vec = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Voltear sprite (no durante el dash)
	if not is_dashing:
		if direction > 0:
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.flip_h = true

	# Iniciar dash
	if Input.is_action_just_pressed("dash") and not is_dashing:
		var on_floor = is_on_floor()
		if on_floor or air_dash_count < MAX_AIR_DASHES:
			start_dash(input_vec, on_floor)

	# Crouch: solo en el suelo y sin dash
	is_crouching = is_on_floor() and not is_dashing and Input.is_action_pressed("move_down")

	# Movimiento
	if is_dashing:
		velocity = dash_dir * DASH_SPEED
	elif is_crouching:
		# Agachado no te mueves (como en Celeste)
		velocity.x = move_toward(velocity.x, 0, SPEED)
	elif direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Squash suave
	var target_scale = CROUCH_SCALE if is_crouching else NORMAL_SCALE
	animated_sprite.scale = animated_sprite.scale.lerp(target_scale, SQUASH_SPEED * delta)
	# Mantener los pies en el suelo al escalar desde el centro
	animated_sprite.position.y = base_sprite_y + SPRITE_HALF_HEIGHT * (1.0 - animated_sprite.scale.y)

	# Animaciones
	if is_dashing:
		pass # aquí puedes reproducir tu animación "dash" si la tienes
	elif is_on_floor():
		if is_crouching or direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	move_and_slide()


func start_dash(input_vec: Vector2, on_floor: bool):
	var dir = input_vec

	# Sin dirección pulsada: dash hacia donde mira el sprite
	if dir == Vector2.ZERO:
		dir = Vector2.LEFT if animated_sprite.flip_h else Vector2.RIGHT
	else:
		# Ajustar a 8 direcciones (múltiplos de 45°)
		var snapped_angle = round(dir.angle() / (PI / 4.0)) * (PI / 4.0)
		dir = Vector2.from_angle(snapped_angle)

	# En el suelo, un dash hacia abajo no tiene sentido: lo hacemos horizontal
	if on_floor and dir.y > 0.1:
		dir.y = 0
		if abs(dir.x) < 0.1:
			dir.x = -1 if animated_sprite.flip_h else 1
		dir = dir.normalized()

	is_dashing = true
	dash_timer = DASH_DURATION
	dash_dir = dir

	# Solo cuenta como dash aéreo si empiezas en el aire
	if not on_floor:
		air_dash_count += 1

	# Orientar el sprite según el dash
	if dir.x > 0.1:
		animated_sprite.flip_h = false
	elif dir.x < -0.1:
		animated_sprite.flip_h = true
