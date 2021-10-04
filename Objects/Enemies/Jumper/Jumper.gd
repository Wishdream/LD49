extends Enemy

export var JUMP_SPEED = 300

func process_attack(_delta):
	play_anim("attack")
	apply_gravity(_delta)
	if is_on_floor():
		change_state(IDLE)

func process_time_end():
	if prev_state == ATTACK:
		change_state(IDLE)
	else:
		change_state(randi()%3)
		var random = randi()%3-1
		if random != 0:
			facing = random
	if state == ATTACK:
		velocity = Vector2(facing * JUMP_SPEED/4, -JUMP_SPEED)
