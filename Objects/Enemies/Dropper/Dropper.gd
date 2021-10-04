extends Enemy

func process_idle(_delta):
	velocity.x = 0
	start_timer(WAIT_TIME)
	play_anim("idle")
	if !is_on_floor():
		timer.stop()
		change_state(ATTACK)
	apply_gravity(_delta)

func process_move(_delta):
	start_timer(WAIT_TIME)
	play_anim("move")
	if velocity.x == 0:
		velocity.x = facing * MOVE_SPEED
	if is_on_wall():
		velocity.x *= -1
	if !is_on_floor():
		timer.stop()
		change_state(ATTACK)
	apply_gravity(_delta)


func process_attack(_delta):
	play_anim("attack")
	apply_gravity(_delta)
	if is_on_floor():
		change_state(IDLE)

func _on_Timer_timeout():
	state = randi()%2
