extends Area2D

@export var default_texture: Texture2D
@export var secret_texture: Texture2D

@onready var sprite := $Sprite2D

func _ready():
	sprite.texture = default_texture

func swap_to_secret():
	if secret_texture:
		sprite.texture = secret_texture
