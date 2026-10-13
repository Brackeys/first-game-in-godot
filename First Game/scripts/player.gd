extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const DASH_SPEED = 400.0
const DASH_DURATION = 0.2
const MAX_JUMPS = 2
const MAX_DASHES = 1
const CROUCH_SCALE = Vector2(1.2, 0.6)   
const NORMAL_SCALE = Vector2(1.0, 1.0)
const SQUASH_SPEED = 50.0                # velocidad de la transición
const SPRITE_HALF_HEIGHT = 8.0           # la mitad de la altura de tu sprite en píxeles
const EXHAUSTED_TEXTURE = preload("res://assets/sprites/knight_exhaustedt.png")
const DASH_FLASH_SHADER = preload("res://shaders/dash_flash.gdshader")
const FLASH_DURATION = 0.15              # duración del flash blanco al dashear
const FLASH_STRENGTH = 0.6               # cuánto se acerca a blanco (0..1)
const DASH_CIRCLE_TIME = 0.28            # duración del circulito tras el dash
const ARCANE_TIME = 0.4                  # duración del círculo arcano

var is_crouching = false
var base_sprite_y = 0.0

var jump_count = 0
var dash_count = 0
var is_dashing = false
var dash_timer = 0.0
var dash_dir = Vector2.RIGHT

# Flash blanco al dashear
var flash_timer = 0.0
var flash_material: ShaderMaterial

# Aspecto "exhausted": se muestra cuando no queda ningún dash disponible
var is_exhausted = false
var normal_frames: SpriteFrames
var exhausted_frames: SpriteFrames

# Efectos del dash
var dash_wind_material: ParticleProcessMaterial
var dash_circle_tween: Tween
var arcane_tween: Tween

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D
@onready var dash_wind = $DashWind
@onready var dash_circle = $DashCircle
@onready var arcane_circle = $ArcaneCircle


func _ready():
	# Guardamos la posición original del sprite para no desplazarlo
	base_sprite_y = animated_sprite.position.y
	# Preparamos una copia de las animaciones usando el atlas "exhausted"
	normal_frames = animated_sprite.sprite_frames
	exhausted_frames = _build_frames_with_atlas(normal_frames, EXHAUSTED_TEXTURE)
	# Material para el flash blanco al dashear
	flash_material = ShaderMaterial.new()
	flash_material.shader = DASH_FLASH_SHADER
	flash_material.set_shader_parameter("flash", 0.0)
	animated_sprite.material = flash_material
	# Efectos del dash (partículas, circulito y círculo arcano)
	dash_wind_material = dash_wind.process_material as ParticleProcessMaterial
	dash_wind.emitting = false
	dash_circle.visible = false
	arcane_circle.visible = false


# Crea unas SpriteFrames nuevas partiendo de las originales, pero sustituyendo
# el atlas de cada frame por la textura indicada. Así conservamos regiones,
# animaciones, velocidades y duraciones sin tocar la escena.
func _build_frames_with_atlas(source: SpriteFrames, atlas_texture: Texture2D) -> SpriteFrames:
	var frames := SpriteFrames.new()
	# SpriteFrames.new() trae una animación "default" que no necesitamos
	if frames.has_animation("default"):
		frames.remove_animation("default")
	for anim in source.get_animation_names():
		frames.add_animation(anim)
		frames.set_animation_speed(anim, source.get_animation_speed(anim))
		frames.set_animation_loop(anim, source.get_animation_loop(anim))
		for i in source.get_frame_count(anim):
			var src_frame = source.get_frame_texture(anim, i) as AtlasTexture
			var new_frame = AtlasTexture.new()
			new_frame.atlas = atlas_texture
			new_frame.region = src_frame.region
			frames.add_frame(anim, new_frame, source.get_frame_duration(anim, i))
	return frames


func _physics_process(delta):
	# Temporizador del dash
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			dash_wind.emitting = false
			# Al terminar, frenamos el impulso vertical hacia arriba
			# para que el dash diagonal/vertical no te catapulte
			if velocity.y < 0:
				velocity.y *= 0.5

	# Flash blanco: se desvanece poco a poco tras iniciar el dash
	if flash_timer > 0.0:
		flash_timer = max(flash_timer - delta, 0.0)
		flash_material.set_shader_parameter("flash", flash_timer / FLASH_DURATION * FLASH_STRENGTH)

	# Gravedad (no se aplica durante el dash)
	if not is_on_floor() and not is_dashing:
		velocity.y += gravity * delta

	# Resetear contadores al tocar el suelo
	if is_on_floor() and not is_dashing:
		jump_count = 0
		dash_count = 0
	elif not is_on_floor() and jump_count == 0:
		# Si caes de una plataforma sin saltar, pierdes el primer salto
		jump_count = 1

	# Aspecto "exhausted": sin dash recargado. En el suelo el dash se recarga,
	# así que solo se muestra en el aire tras gastar el dash. Durante el propio
	# dash se mantiene el aspecto normal, como en Celeste.
	_set_exhausted(not is_dashing and not is_on_floor() and dash_count >= MAX_DASHES)

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
		if on_floor or dash_count < MAX_DASHES:
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

	# El dash siempre consume el dash. Si al terminar sigues en el suelo, se
	# recarga en el siguiente frame, por lo que un dash horizontal a ras de
	# suelo no lo gasta. Si el dash te despega (vertical/diagonal arriba, o al
	# salir de una plataforma), se queda gastado hasta que vuelvas a aterrizar.
	dash_count += 1

	# Flash blanco al iniciar el dash
	flash_timer = FLASH_DURATION
	flash_material.set_shader_parameter("flash", FLASH_STRENGTH)

	# Efectos visuales del dash
	_play_dash_vfx(dir)

	# Orientar el sprite según el dash
	if dir.x > 0.1:
		animated_sprite.flip_h = false
	elif dir.x < -0.1:
		animated_sprite.flip_h = true


# Cambia entre el aspecto normal y el "exhausted", conservando la animación actual
func _set_exhausted(value: bool):
	if value == is_exhausted:
		return
	is_exhausted = value
	var current_anim = animated_sprite.animation
	var current_frame = animated_sprite.frame
	animated_sprite.sprite_frames = exhausted_frames if is_exhausted else normal_frames
	# Reanudamos la animación en el mismo frame para que se refresque la textura
	# mostrada sin que el sprite dé un salto visible.
	animated_sprite.play(current_anim)
	animated_sprite.frame = current_frame


# Lanza los efectos visuales del dash: viento, circulito y círculo arcano
func _play_dash_vfx(dir: Vector2):
	# "Detrás" = dirección opuesta al dash
	var behind = -dir.normalized()
	var pivot = Vector2(0, -12) # centro del sprite del personaje

	# --- Viento / velocidad: partículas que salen hacia atrás ---
	dash_wind_material.direction = Vector3(behind.x, behind.y, 0.0)
	dash_wind.emitting = true

	# --- Circulito pequeño detrás (estilo Guilty Gear) ---
	if dash_circle_tween and dash_circle_tween.is_valid():
		dash_circle_tween.kill()
	dash_circle.visible = true
	dash_circle.position = pivot + behind * 15.0
	dash_circle.rotation = 0.0
	dash_circle.scale = Vector2(0.5, 0.5)
	dash_circle.modulate = Color(1, 1, 1, 1)
	dash_circle_tween = create_tween()
	dash_circle_tween.tween_property(dash_circle, "scale", Vector2(1.5, 1.5), DASH_CIRCLE_TIME)
	dash_circle_tween.parallel().tween_property(dash_circle, "modulate:a", 0.0, DASH_CIRCLE_TIME)
	dash_circle_tween.tween_callback(dash_circle.hide)
