extends EntityObject
class_name Enemy

export var WAIT_TIME : float = 2.0
var gold_tender = load("res://Objects/Scrap/Scrap.tscn")

enum {IDLE, MOVE, ATTACK}
onready var timer = get_node("Timer")

func _ready():
	sprite.flip_h = facing == 1
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
	if !grounded:
		timer.stop()
		change_state(IDLE)
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


func deal_damage(value):
	if hp - value < 1:
		hp = 0
		var amount = 3.0 * Run.scrap_rate
		for i in range(amount):
			var scrap = gold_tender.instance()
			get_tree().get_current_scene().call_deferred("add_child", scrap)
			scrap.position = global_position
			var amount_norm = i/(amount-1)
			scrap.velocity.x = lerp(-100, 100, amount_norm)
			#var curve_height = abs(amount_norm - floor(amount_norm + 0.5))
			var curve_height = sin(amount_norm * (PI))
			scrap.BOUNCE_SPEED = lerp(200, scrap.BOUNCE_SPEED, curve_height) 
			scrap.velocity.y = -scrap.BOUNCE_SPEED
		call_deferred("queue_free")
	else:
		hp -= value * Run.attack_rate
		$AnimationPlayer.play("sharp_flash")


func _on_Timer_timeout():
	process_time_end()


func _on_Hitbox_area_entered(area):
	if area.get_collision_layer_bit(9):
		call_deferred("free")
	else:
		deal_damage(area.get_parent().damage_value * Run.attack_rate)
