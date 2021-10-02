extends Node

var parent
var anim
var main_pos = Vector2()
var fall_rate = 3

func _ready():
	parent = get_parent()
	anim = get_parent().get_node("Sprite")
	main_pos = get_parent().position

func update_position(build_rate):
	parent.position = main_pos + Vector2(0,build_rate)

func _on_Platform_update_tick():
	update_position(fall_rate * anim.frame)
