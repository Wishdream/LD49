extends KinematicBody2D

var velocity = Vector2.ZERO
var FALL_SPEED = 300
var BOUNCE_SPEED = 300
var BOUNCE_RATE = 25
var scrap_value = 3

func _physics_process(delta):
	apply_gravity(delta)
	velocity = move_and_slide(velocity, Vector2.UP)
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, 5)
		BOUNCE_SPEED -= BOUNCE_RATE
		velocity.y = -BOUNCE_SPEED
	
func apply_gravity(_delta):
	velocity += Vector2(0,Global.GRAVITY) * _delta
	if velocity.y > FALL_SPEED:
		velocity.y = FALL_SPEED

func _on_Timer_timeout():
	call_deferred("free")
