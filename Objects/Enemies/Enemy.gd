extends EntityObject
class_name Enemy

export var WAIT_TIME : float = 2.0

enum {IDLE, MOVE, ATTACK}
onready var animator = get_node("Sprite")
onready var timer = get_node("Timer")


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
	play_anim("walk")
	if velocity.x == 0:
		velocity.x = facing * MOVE_SPEED
	if !is_on_floor() or is_on_wall():
		velocity.x *= -1
	apply_gravity(_delta)


func process_attack(_delta):
	velocity.x = 0
	start_timer(WAIT_TIME/6)
	play_anim("attack")
	apply_gravity(_delta)


func play_anim(animation : String):
	if animator != null:
		animator.play(animation)


func start_timer(time : float):
	if timer.is_stopped(): timer.start(time)


func _on_Timer_timeout():
	state = randi()%3


func _on_Hitbox_area_entered(area):
	deal_damage(area.get_parent().damage_value)
