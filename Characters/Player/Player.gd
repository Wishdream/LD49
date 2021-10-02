extends KinematicBody2D
#==============================================================================
# Constants and Variables
#==============================================================================
const MOVE_SPEED = 120
const JUMP_SPEED = 200
const DASH_SPEED = 250
const DODGE_SPEED = 400
const FALL_SPEED = 400
const DFALL_SPEED = 500

const DASH_TIME = 0.4
const DODGE_TIME = 0.2
const HURT_TIME = 0.2
const JUMP_TIME = 0.3
const COYOTE_TIME = 0.15
const DOWN_TIME = 2

enum {
	IDLE,
	MOVE,
	DASH,
	JUMP,
	FALL,
	DODGE,
	HURT,
	AERIAL,
	CLIMB,
	DOWN
}

var hpmax = 100
var hp = hpmax
var dashed = false
var dodged = false
var climbing = false
var on_ladder = false
var velocity = Vector2.ZERO
var prev_state = null
var state = FALL

onready var sprite = get_node("Sprite")
onready var timer = get_node("Timer")
onready var particles = get_node("Particles")
onready var anim_player = get_node("AnimationPlayer")
onready var ladderbox = get_node("Ladderbox")

#==============================================================================
# Functions
#==============================================================================

func _process(delta):

	var dir = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_pressed("move_right"):
		dir.x += 1
	if Input.is_action_pressed("move_up"):
		dir.y -= 1
	if Input.is_action_pressed("move_down"):
		dir.y += 1

	match state:
		IDLE:
			process_idle(dir)
		MOVE:
			process_move(dir)
		DASH:
			process_dash()
		JUMP:
			process_jump(dir, delta)
		FALL:
			process_fall(dir, delta)
		DODGE:
			process_dodge(dir)
		CLIMB:
			process_climb(dir)
		HURT:
			process_hurt()
		AERIAL:
			process_aerial(dir)
		DOWN:
			process_death()
			
	process_attack()
	process_build()
	process_movement(delta)

func change_state(new_state):
	prev_state = state
	state = new_state

func set_damage(value):
	hp -= value
	dashed = false
	if (value > 0):
		timer.start(HURT_TIME)
		change_state(HURT)

func process_movement(_delta):
	particles.emitting = dashed
	velocity = move_and_slide(velocity, Vector2.UP)
	pass

func apply_gravity():
	velocity += Vector2(0,Global.GRAVITY)
	var fspeed
	if dashed:
		fspeed = DFALL_SPEED
	else:
		fspeed = FALL_SPEED
	if velocity.y > fspeed:
		velocity.y = fspeed

#==============================================================================
# States
#==============================================================================

func process_idle(dir):
	dodged = false
	dashed = false
	if dir.x != 0:
		change_state(MOVE)
	else:
		velocity.x = 0
	if Input.is_action_just_pressed("jump") and is_on_floor():
		change_state(JUMP)
	if Input.is_action_just_pressed("dash"):
		change_state(DASH)
	if Input.is_action_just_pressed("dodge"):
		change_state(DODGE)
	if Input.is_action_just_pressed("move_up") and on_ladder:
		change_state(CLIMB)

	if Input.is_action_pressed("move_down"):
		sprite.play("sit")
	else:
		sprite.play("idle")

	if not is_on_floor():
		change_state(FALL)

	apply_gravity()

func process_move(dir):
	sprite.play("run")
	if dir.x == 0:
		change_state(IDLE)
	else:
		sprite.flip_h = dir.x < 0

	velocity.x = dir.x * MOVE_SPEED

	if Input.is_action_just_pressed("jump") and is_on_floor():
		change_state(JUMP)
	if Input.is_action_just_pressed("dash"):
		change_state(DASH)
	if Input.is_action_just_pressed("dodge"):
		change_state(DODGE)
	if Input.is_action_just_pressed("move_up") and on_ladder:
		change_state(CLIMB)

	if not is_on_floor():
		change_state(FALL)

	apply_gravity()

func process_jump(dir, delta):
	sprite.play("air up")

	if Input.is_action_pressed("jump") and is_on_floor():
		timer.start(JUMP_TIME)
		velocity.y = -JUMP_SPEED

	if dir.x != 0:
		var speed
		if dashed:
			speed = DASH_SPEED
		else:
			speed = MOVE_SPEED
		velocity.x = move_toward(velocity.x, dir.x * speed, 25)
		sprite.flip_h = dir.x < 0
	else:
		velocity.x = move_toward(velocity.x, 0, 25*delta)

	if Input.is_action_just_released("jump"):
		timer.stop()
		change_state(FALL)
	
	if Input.is_action_just_pressed("move_up") and on_ladder:
		change_state(CLIMB)
		
	if Input.is_action_just_pressed("dodge") and not dodged:
		change_state(DODGE)

func process_dash():
	sprite.play("dash")
	dashed = true
	velocity.x = DASH_SPEED * (1 + (-2 * int(sprite.flip_h)) )
	if timer.is_stopped():
		timer.start(DASH_TIME)
	if Input.is_action_just_pressed("jump"):
		timer.start(JUMP_TIME)
		velocity.y = -JUMP_SPEED
		change_state(JUMP)
	if Input.is_action_just_released("dash"):
		velocity = Vector2.ZERO
		change_state(IDLE)
	pass

func process_fall(dir, delta):
	if prev_state == IDLE or prev_state == MOVE or prev_state == DASH:
		if timer.is_stopped():
			timer.start(COYOTE_TIME)
		if Input.is_action_just_pressed("jump"):
			timer.start(JUMP_TIME)
			velocity.y = -JUMP_SPEED
			change_state(JUMP)
			timer.stop()

	if dir.x != 0:
		var speed
		if dashed:
			speed = DASH_SPEED
		else:
			speed = MOVE_SPEED
		velocity.x = move_toward(velocity.x, dir.x * speed, 25)
		sprite.flip_h = dir.x < 0
	else:
		velocity.x = move_toward(velocity.x, 0, 25*delta)

	if velocity.y > 0:
		sprite.play("air dn")

	if is_on_floor():
		change_state(IDLE)

	if dir.y == -1 and on_ladder:
			change_state(CLIMB)

	if Input.is_action_just_pressed("jump") and Run.aerial != Global.AERIAL.NONE:
		change_state(AERIAL)

	if Input.is_action_just_pressed("dodge") and not dodged:
		timer.stop()
		change_state(DODGE)

	apply_gravity()

func process_dodge(dir):
	sprite.play("dodge")
	if timer.is_stopped():
		timer.start(DODGE_TIME)
		dodged = true
		velocity = dir * DODGE_SPEED
		sprite.flip_h = dir.x < 0
	if timer.time_left < 0.06:
		velocity = Vector2.ZERO
		
func process_climb(dir):
	sprite.play("run")
	velocity = dir * MOVE_SPEED
	
	if dir != Vector2.ZERO:
		sprite.playing = true
	else:
		sprite.playing = false
		
	if Input.is_action_just_pressed("jump"):
		timer.start(JUMP_TIME)
		velocity.y = -JUMP_SPEED
		sprite.playing = true
		change_state(JUMP)
	if Input.is_action_just_pressed("dodge"):
		sprite.playing = true
		change_state(DODGE)

func process_hurt():
	if prev_state != CLIMB:
		velocity.x = -DASH_SPEED * (1 + (-2 * int(sprite.flip_h)))
		velocity.y = 0
	sprite.play("hurt")
	if hp < 1:
		change_state(DOWN)
		timer.stop()

func process_aerial(dir):
	match Run.aerial:
		Global.AERIAL.AIR_DASH:
			pass
		Global.AERIAL.DOUBLE_JUMP:
			pass
		Global.AERIAL.HOOK:
			pass
		Global.AERIAL.JET:
			pass
	pass

func process_attack():
	pass

func process_build():
	pass
	
func process_death():
	sprite.play("hurt")
	if is_on_floor():
		if abs(velocity.x) > 1:
			velocity.x = lerp(velocity.x, 0, 0.15)
		else:
			velocity.x = 0
		sprite.play("down")
		timer.start(DOWN_TIME)
	apply_gravity()

#==============================================================================
# Signals
#==============================================================================

func _on_Timer_timeout():
	if state == HURT:
		velocity = Vector2.ZERO
	if state == DOWN:
		get_tree().quit()
	change_state(FALL)


func _on_Hitbox_area_entered(_area):
	set_damage(5)


func _on_Ladderbox_area_entered(_area):
	on_ladder = true


func _on_Ladderbox_area_exited(_area):
	if $Ladderbox.get_overlapping_areas().size() == 0:
		if state == CLIMB: change_state(FALL)
		on_ladder = false
		sprite.playing = true
