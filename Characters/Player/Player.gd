extends KinematicBody2D
#==============================================================================
# Constants and Variables
#==============================================================================
const MOVE_SPEED = 120
const JUMP_SPEED = 300
const DASH_SPEED = 300
const DODGE_SPEED = 400
const FALL_SPEED = 400
const DFALL_SPEED = 500

const DASH_TIME = 0.3
const DODGE_TIME = 0.2
const HURT_TIME = 0.2
const JUMP_TIME = 0.1
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
var dir = Vector2.ZERO
var dashed = false
var dodged = false
var aerialed = false
var climbing = false
var on_ladder = false
var is_attacking = false
var is_building = false
var boom_throw = false
var velocity = Vector2.ZERO
var prev_state = null
var state = FALL

onready var sprite = get_node("Sprite")
onready var move_timer = get_node("MoveTimer")
onready var inv_timer = get_node("InvTimer")
onready var swing_timer = get_node("SwingTimer")
onready var particles = get_node("Particles")
onready var anim_player = get_node("AnimationPlayer")
onready var ladderbox = get_node("Ladderbox")
onready var hand_pivot = get_node("HandPivot")
onready var hand_object = get_node("HandPivot/Hand")
onready var hand_anim = get_node("HandPivot/Hand/AnimationPlayer")
onready var attacks = get_node("Attacks")
onready var spawn_mel = get_node("HandPivot/MelSpawn")
onready var spawn_proj = get_node("HandPivot/ProjSpawn")

#==============================================================================
# Functions
#==============================================================================

func _ready():
	hand_anim.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	hand_anim.play("idle")

func _physics_process(delta):

	dir = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_pressed("move_right"):
		dir.x += 1
	if Input.is_action_pressed("move_up"):
		dir.y -= 1
	if Input.is_action_pressed("move_down"):
		dir.y += 1
	
	var facing = 1 + (-2 * int(sprite.flip_h))

	match state:
		IDLE:
			process_idle(delta, dir)
		MOVE:
			process_move(delta, dir)
		DASH:
			process_dash(delta, facing)
		JUMP:
			process_jump(delta, dir)
		FALL:
			process_fall(delta, dir)
		DODGE:
			process_dodge(delta, dir)
		CLIMB:
			process_climb(delta, dir)
		HURT:
			process_hurt(delta, facing)
		AERIAL:
			process_aerial(delta, dir, facing)
		DOWN:
			process_death(delta)

	process_attack(facing)
	process_build(facing)
	process_movement(delta, facing)

func change_state(new_state):
	prev_state = state
	state = new_state

func take_damage(value):
	hp -= value
	dashed = false
	if (value > 0):
		move_timer.start(HURT_TIME)
		change_state(HURT)

func process_movement(_delta, facing):
	if not aerialed: particles.emitting = dashed
	hand_pivot.scale.x = facing
	velocity = move_and_slide(velocity, Vector2.UP)
	pass

func apply_gravity(_delta):
	velocity += Vector2(0,Global.GRAVITY) * _delta
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

# Idle
func process_idle(delta, dir):
	if dodged: dodged = false
	if dashed: dashed = false
	if aerialed: aerialed = false

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

	apply_gravity(delta)


# Ground Move
func process_move(delta, dir):
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

	apply_gravity(delta)


# Jump
func process_jump(delta, dir):

	if move_timer.is_stopped():
		move_timer.start(JUMP_TIME)
		sprite.play("air up")

	# Dash Modifier
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

	if Input.is_action_pressed("jump"):
		velocity.y = -JUMP_SPEED

	if Input.is_action_just_released("jump"):
		move_timer.stop()
		velocity.y /= 1.5
		change_state(FALL)

	if Input.is_action_just_pressed("move_up") and on_ladder:
		change_state(CLIMB)

	if Input.is_action_just_pressed("dodge") and not dodged:
		change_state(DODGE)


# Dash
func process_dash(_delta, facing):
	sprite.play("dash")
	dashed = true

	velocity.x = DASH_SPEED * facing

	if move_timer.is_stopped():
		move_timer.start(DASH_TIME)

	if Input.is_action_just_pressed("jump"):
		move_timer.start(JUMP_TIME)
		velocity.y = -JUMP_SPEED
		change_state(JUMP)

	if Input.is_action_just_released("dash"):
		velocity = Vector2.ZERO
		change_state(IDLE)


# Fall
func process_fall(delta, dir):
	if prev_state == IDLE or prev_state == MOVE or prev_state == DASH:
		if move_timer.is_stopped():
			move_timer.start(COYOTE_TIME)
		if Input.is_action_just_pressed("jump"):
			move_timer.start(JUMP_TIME)
			velocity.y = -JUMP_SPEED
			change_state(JUMP)
			move_timer.stop()

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

	if Input.is_action_just_pressed("jump") and Run.aerial != Global.AERIAL.NONE and not aerialed:
		change_state(AERIAL)
	else:
		particles.emitting = false

	if dir.y == -1 and on_ladder:
			change_state(CLIMB)

	if Input.is_action_just_pressed("dodge") and not dodged:
		move_timer.stop()
		change_state(DODGE)

	apply_gravity(delta)


# Dodge
func process_dodge(_delta, dir):
	sprite.play("dodge")
	if move_timer.is_stopped():
		move_timer.start(DODGE_TIME)
		dodged = true
		velocity = dir * DODGE_SPEED
		sprite.flip_h = dir.x < 0
	if move_timer.time_left < 0.06:
		velocity = Vector2.ZERO


# Climbing
func process_climb(_delta, dir):
	sprite.play("climb")
	if dir.x != 0: sprite.flip_h = dir.x < 0
	velocity = dir * MOVE_SPEED

	if dir != Vector2.ZERO:
		sprite.playing = true
	else:
		sprite.playing = false

	if Input.is_action_just_pressed("jump"):
		move_timer.start(JUMP_TIME)
		velocity.y = -JUMP_SPEED
		sprite.playing = true
		change_state(JUMP)
	if Input.is_action_just_pressed("dodge"):
		sprite.playing = true
		change_state(DODGE)


# Hurt / Damage
func process_hurt(_delta, facing):
	if prev_state != CLIMB:
		velocity.x = -DASH_SPEED * facing
		velocity.y = 0
	sprite.play("hurt")
	particles.emitting = false
	dashed = false
	if hp < 1:
		change_state(DOWN)
		move_timer.stop()


# Aerial / Secondary Movement
func process_aerial(_delta, dir, facing):

	if !aerialed: aerialed = true

	match Run.aerial:

		# Aerial Dash
		Global.AERIAL.AIR_DASH:
			if move_timer.is_stopped():
				move_timer.start(DASH_TIME)
				sprite.play("dash")
				particles.emitting = true
				velocity.x = DASH_SPEED * facing
				velocity.y = 0
			if move_timer.time_left < 0.02:
				velocity.x /= 4


		# Double Jump
		Global.AERIAL.DOUBLE_JUMP:
			particles.emitting = true
			change_state(JUMP)

		# Skyhook
		Global.AERIAL.HOOK:
			pass

		# Skyjet
		Global.AERIAL.JET:
			pass


# Attacks
func process_attack(facing):
	if state != HURT or state != DOWN:
		if Input.is_action_just_pressed("attack") and swing_timer.time_left < 0.1:
			
			# Graphic and stat changes
			match Run.weapon:
				Global.WEAPON.DAGGER:
					hand_object.frame = 22
				Global.WEAPON.SWORD:
					hand_object.frame = 0
				Global.WEAPON.SPEAR:
					hand_object.frame = 1
				Global.WEAPON.HAMMER:
					hand_object.frame = 2
				Global.WEAPON.PISTOL:
					hand_object.frame = 3
				Global.WEAPON.SHURIKEN:
					hand_object.frame = 4
					
			is_attacking = true
			var pos
			if Run.weapon > 3:
				pos = spawn_proj.global_position
				hand_anim.play_backwards("swing")
			else:
				pos = spawn_mel.global_position
				hand_anim.play("swing")
				
			attacks.shoot_attack(pos, facing, Run.weapon)


# Build
func process_build(facing):
	if state != HURT or state != DOWN:
		if Input.is_action_just_pressed("build") and swing_timer.time_left < 0.1:
			
			# Graphic and stat changes
			match Run.hammer:
				Global.HAMMER.NORMAL:
					hand_object.frame = 5
				Global.HAMMER.BOOMER:
					hand_object.frame = 6
					# Skip if boom not in hand
					# if boom_throw: return
					# boom_throw = true
				Global.HAMMER.SPIKE:
					hand_object.frame = 7
				Global.HAMMER.BETTER:
					hand_object.frame = 8
				Global.HAMMER.AREA:
					hand_object.frame = 9
			
			var pos = spawn_mel.global_position
			attacks.shoot_build(pos, facing, Run.hammer)
			is_attacking = true
			hand_anim.play("swing")


# Downstate
func process_death(_delta):
	hand_object.visible = false
	sprite.play("hurt")
	if is_on_floor():
		if abs(velocity.x) > 1:
			velocity.x = lerp(velocity.x, 0, 0.15)
		else:
			velocity.x = 0
		sprite.play("down")
		move_timer.start(DOWN_TIME)
	apply_gravity(_delta)


#==============================================================================
# Signals
#==============================================================================

func _on_MoveTimer_timeout():
	if state == HURT:
		velocity = Vector2.ZERO
	if state == DOWN:
		get_tree().quit()
	change_state(FALL)


func _on_Hitbox_area_entered(_area):
	if (_area.get("damage_value") == null):
		take_damage(5)
	else:
		take_damage(_area.damage_value)


func _on_Ladderbox_area_entered(_area):
	on_ladder = true


func _on_Ladderbox_area_exited(_area):
	if $Ladderbox.get_overlapping_areas().size() == 0:
		if state == CLIMB: change_state(FALL)
		on_ladder = false
		sprite.playing = true


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "swing":
		is_attacking = false
		hand_anim.play("idle")

