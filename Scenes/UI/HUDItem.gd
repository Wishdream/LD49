extends Control

export var index:int = 0 setget set_index

func set_index(value):
	$Sprite.frame = value
