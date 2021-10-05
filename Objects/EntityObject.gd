extends KinematicBody2D
class_name EntityObject

export var MOVE_SPEED = 25
export var FALL_SPEED = 400

enum facing_dir {LEFT = -1, RIGHT = 1}
export(facing_dir) var facing = -1

export var hp_max = 10
var hp = hp_max

var velocity = Vector2.ZERO
var prev_state = null
var state = 0
var grounded = false

onready var sprite = get_node("Sprite")

func deal_damage(value):
	if hp < 0:
		hp = 0
		call_deferred("queue_free")
	else:
		hp -= value * Run.attack_rate

func process_movement(_delta, _facing = 1):
	if velocity.x != 0:
		facing = sign(velocity.x)
		sprite.flip_h = facing == 1
	grounded = is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP)

func change_state(new_state):
	prev_state = state
	state = new_state

func apply_gravity(_delta):
	velocity += Vector2(0,Global.GRAVITY) * _delta
	if velocity.y > FALL_SPEED:
		velocity.y = FALL_SPEED

func check_ground_move(move_speed):
	var check = Vector2(move_speed * facing, Global.GRAVITY)
	return test_move(transform, check)
