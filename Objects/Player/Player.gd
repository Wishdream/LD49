extends EntityObject
#==============================================================================
# Constants and Variables
#==============================================================================
export var JUMP_SPEED = 300
export var DASH_SPEED = 300
export var DODGE_SPEED = 400
export var DFALL_SPEED = 500

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

var dir = Vector2.ZERO
var dashed:bool = false
var dodged:bool = false
var aerialed:bool = false
var climbing:bool = false
var on_ladder:bool = false
var is_attacking:bool = false
var is_building:bool = false
var boom_throw:bool = false

#onready var sprite:AnimatedSprite = get_node("Sprite")
onready var move_timer:Timer = get_node("MoveTimer")
onready var inv_timer:Timer = get_node("InvTimer")
onready var swing_timer:Timer = get_node("SwingTimer")
onready var particles:CPUParticles2D = get_node("Particles")
onready var anim_player:AnimationPlayer = get_node("AnimationPlayer")
onready var ladderbox:Area2D = get_node("Ladderbox")
onready var hand_pivot:Node2D = get_node("HandPivot")
onready var hand_object:Sprite = get_node("HandPivot/Hand")
onready var hand_anim:AnimationPlayer = get_node("HandPivot/Hand/AnimationPlayer")
onready var attacks:Node = get_node("Attacks")
onready var spawn_mel:Position2D = get_node("HandPivot/MelSpawn")
onready var spawn_proj:Position2D = get_node("HandPivot/ProjSpawn")

signal hp_changed(new_hp)
signal scrap_changed()
signal items_changed()

#==============================================================================
# Functions
#==============================================================================

func _ready():
	prev_state = null
	state = FALL
	var _signal = hand_anim.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	hand_anim.play("idle")
	hand_object.frame = Global.weapon_sprite_index[Run.weapon]

	emit_signal("hp_changed", hp)

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

	facing = 1 + (-2 * int(sprite.flip_h))

	match state:
		IDLE:
			process_idle(delta)
		MOVE:
			process_move(delta)
		DASH:
			process_dash(delta, facing)
		JUMP:
			process_jump(delta)
		FALL:
			process_fall(delta)
		DODGE:
			process_dodge(delta)
		CLIMB:
			process_climb(delta)
		HURT:
			process_hurt(delta, facing)
		AERIAL:
			process_aerial(delta, facing)
		DOWN:
			process_death(delta)

	process_attack(facing)
	process_build(facing)
	process_movement(delta, facing)

func take_damage(value):
	hp -= value
	dashed = false
	emit_signal("hp_changed", hp)

	if (value > 0):
		move_timer.start(HURT_TIME)
		change_state(HURT)
		
func update_items():
	emit_signal("items_changed")
	
func give_scrap(value):
	Run.scrap += value
	emit_signal("scrap_changed")

func process_movement(_delta, _facing = 1):
	if not aerialed: particles.emitting = dashed
	hand_pivot.scale.x = facing
	velocity = move_and_slide(velocity, Vector2.UP)
	grounded = is_on_floor()


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
func process_idle(delta):
	# Clear timer, there is no timer on this state
	if !move_timer.is_stopped():
		move_timer.stop()
		
	if dodged: dodged = false
	if dashed: dashed = false
	if aerialed: aerialed = false

	if dir.x != 0:
		change_state(MOVE)
	else:
		velocity.x = 0
	if Input.is_action_just_pressed("jump") and grounded:
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

	if not grounded:
		change_state(FALL)

	apply_gravity(delta)


# Ground Move
func process_move(delta):
	# Clear timer, there is no timer on this state
	if !move_timer.is_stopped():
		move_timer.stop()
	
	sprite.play("run")
	if dir.x == 0:
		change_state(IDLE)
	else:
		sprite.flip_h = dir.x < 0

	velocity.x = dir.x * MOVE_SPEED

	if Input.is_action_just_pressed("jump") and grounded:
		change_state(JUMP)
	if Input.is_action_just_pressed("dash"):
		change_state(DASH)
	if Input.is_action_just_pressed("dodge"):
		change_state(DODGE)
	if Input.is_action_just_pressed("move_up") and on_ladder:
		change_state(CLIMB)

	if not grounded:
		change_state(FALL)

	apply_gravity(delta)


# Jump
func process_jump(delta):

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

	var wait_time = move_timer.wait_time
	if Input.is_action_just_released("dash") and move_timer.time_left < wait_time - wait_time/4:
		velocity.x = 0
		change_state(MOVE)

	if !grounded:
		change_state(FALL)

	apply_gravity(_delta)


# Fall
func process_fall(delta):
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

	apply_gravity(delta)

	if grounded:
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


# Dodge
func process_dodge(_delta):
	sprite.play("dodge")
	if move_timer.is_stopped():
		move_timer.start(DODGE_TIME)
		dodged = true
		velocity = dir * DODGE_SPEED
		sprite.flip_h = dir.x < 0
	if move_timer.time_left < 0.06:
		velocity = Vector2.ZERO


# Climbing
func process_climb(_delta):
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
func process_aerial(_delta, facing):

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
	if state != HURT and state != DOWN and Run.attack_rate > 0:
		if Input.is_action_just_pressed("attack") and swing_timer.time_left < 0.1:

			# Graphic and stat changes
			hand_object.frame = Global.weapon_sprite_index[Run.weapon]

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
	if state != HURT and state != DOWN and Run.build_rate > 0:
		if Input.is_action_just_pressed("build") and swing_timer.time_left < 0.1:

			# Graphic and stat changes
			hand_object.frame = Global.hammer_sprite_index[Run.hammer]

			var pos = spawn_mel.global_position
			attacks.shoot_build(pos, facing, Run.hammer)
			is_attacking = true
			hand_anim.play("swing")


# Downstate
func process_death(_delta):
	hand_object.visible = false
	sprite.play("hurt")
	if grounded:
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
	if state == DASH:
		change_state(IDLE)
	elif state != FALL and state != IDLE and state != MOVE:
		change_state(FALL)


func _on_Hitbox_area_entered(_area):
	if _area.get_collision_layer_bit(5):
		if (_area.get("damage_value") == null):
			take_damage(1)
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


func _on_Hitbox_body_entered(body):
	if body.get_collision_layer_bit(6):
		give_scrap(body.scrap_value)
		body.queue_free()
