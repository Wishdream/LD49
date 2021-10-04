extends StaticBody2D

var main_pos = Vector2()
var vel = 0
var is_hit = false
var parent
var timer
export var RESTORE_RATE = 400

func _ready():
	main_pos = position
	parent = get_parent()
	timer = get_node("Timer")


func _physics_process(_delta):
	if parent.sprite_anim.frame == parent.sprite_max:
		position.y += (vel * 1.5) * _delta
	elif timer.is_stopped(): 
		position.y += vel * _delta


func _on_Platform_start_fall():
	vel = 10 * Run.decay_rate
	

func _on_Hitbox_area_entered(_area):
	if _area.get_collision_layer_bit(4):
		repair_platform(_area)
	
	
func repair_platform(_area):
	position.y -= RESTORE_RATE / 60
	timer.start()
	if position.y < main_pos.y:
		position = main_pos
		timer.stop()

func _on_Exit_area_entered(area):
	if area == $ExitChecker:
		vel = 100
		$ExitChecker/ExitPlayer.play("fall")
		set_collision_layer_bit(1, false)

func _on_ExitPlayer_animation_finished(_anim_name):
	get_parent().queue_free()
