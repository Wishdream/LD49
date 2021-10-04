extends Enemy

export var ATTACK_SPEED = 50

func process_idle(_delta):
	velocity.x = 0
	start_timer(WAIT_TIME)
	play_anim("move")


func process_move(_delta):
	start_timer(WAIT_TIME)
	play_anim("move")
	
	velocity.x = facing * MOVE_SPEED
	if is_on_wall():
		velocity.x *= -1

func process_attack(_delta):
	velocity.x = facing * ATTACK_SPEED
	start_timer(WAIT_TIME/2)
	play_anim("attack")

func process_time_end():
	change_state(randi()%3)
	if prev_state == ATTACK:
		change_state(IDLE)
	else:
		var random = randi()%3-1
		if random != 0:
			facing = random
