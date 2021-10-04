extends Enemy

func process_move(_delta):
	start_timer(WAIT_TIME)
	play_anim("walk")
	if velocity.x == 0:
		velocity.x = facing * MOVE_SPEED
