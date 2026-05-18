extends Node2D

@export var switch_id: int = 1

func turn_on():
	$Off.visible = false
	$On.visible = true
