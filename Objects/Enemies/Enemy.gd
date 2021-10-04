extends EntityObject
class_name Enemy

export var WAIT_TIME : float = 2.0

enum {IDLE, MOVE, ATTACK}
onready var timer = get_node("Timer")

func _ready():
	timer.wait_time = WAIT_TIME

func _physics_process(delta):
	match state:
		IDLE:
			process_idle(delta)
		MOVE:
			process_move(delta)
		ATTACK:
			process_attack(delta)
	process_movement(delta)


func process_idle(_delta):
	velocity.x = 0
	start_timer(WAIT_TIME)
	play_anim("idle")
	apply_gravity(_delta)


func process_move(_delta):
	start_timer(WAIT_TIME)
	play_anim("move")
	if velocity.x == 0:
		velocity.x = facing * MOVE_SPEED
	if (!check_ground_move() and grounded) or is_on_wall():
		velocity.x *= -1
	apply_gravity(_delta)


func process_attack(_delta):
	velocity.x = 0
	start_timer(WAIT_TIME/4)
	play_anim("attack")
	apply_gravity(_delta)


func process_time_end():
	if state == ATTACK:
		change_state(IDLE)
	else:
		var random = randi()%3-1
		if random != 0:
			facing = random
		change_state(randi()%3)


func play_anim(animation : String):
	if sprite != null:
		sprite.play(animation)


func start_timer(time : float):
	if timer.is_stopped(): timer.start(time)


func _on_Timer_timeout():
	process_time_end()


func _on_Hitbox_area_entered(area):
	deal_damage(area.get_parent().damage_value)
