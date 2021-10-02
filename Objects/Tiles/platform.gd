extends KinematicBody2D

var main_pos = Vector2()
var vel = Vector2.ZERO
var is_hit = false
var parent
var timer

func _ready():
	main_pos = position
	parent = get_parent()
	timer = get_node("Timer")


func _physics_process(delta):
	if parent.sprite_anim.frame == parent.sprite_max:
		move_and_slide(vel * 1.5)
	elif timer.is_stopped(): 
		move_and_slide(vel)


func _on_Platform_start_fall():
	vel = Vector2(0, 10 * Run.decay_rate)
	


func _on_Hitbox_area_entered(area):
	repair_platform()


func repair_platform():
	move_and_slide(Vector2(0, -200) * Run.build_rate)
	if position.y < main_pos.y:
		position = main_pos
		timer.stop()
	else:
		timer.start()
