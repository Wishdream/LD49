extends KinematicBody2D
class_name EntityObject

export var MOVE_SPEED = 100
export var FALL_SPEED = 400

export var hp_max = 10
var hp = hp_max
var facing

var velocity = Vector2.ZERO
var prev_state = null
var state = 0

func deal_damage(value):
	if hp < 0:
		hp = 0
	else:
		hp -= value

func process_movement(_delta, _facing):
	if velocity.x != 0:
		facing = sign(velocity.x)
	velocity = move_and_slide(velocity)
