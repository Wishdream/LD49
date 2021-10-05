extends Control

export var index:int = 0 setget set_index
export var count:int = 0 setget set_count

func _ready():
	set_count(0)
	
func set_index(value):
	index = value
	$Sprite.frame = value

func set_count(value):
	count = value
	$Label.visible = bool(value > 1)
	$Label.text = str(value)
