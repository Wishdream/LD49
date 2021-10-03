extends Node2D
class_name Attack

export(int, 0, 100) var damage_value
export(int, 0, 3) var build_value
export(float) var damage_time = 0.1
export(int, "Attack", "Build", "Damage", "Double") var damage_type = 0
export(int, "Melee", "Projectile") var attack_type = 0
export(Vector2) var velocity = Vector2.ZERO

func set_bullet():
	if damage_type == 0: # Attack
		$Hitbox.set_collision_layer_bit(3,true)
	if damage_type == 1: # Build
		$Hitbox.set_collision_layer_bit(4, true)
	if damage_type == 2: # Damage
		$Hitbox.set_collision_layer_bit(2, true)
	if damage_type == 3: # Double
		$Hitbox.set_collision_layer_bit(3, true)
		$Hitbox.set_collision_layer_bit(4, true)
	if attack_type == 1:
		$Hitbox.monitoring = true
	$Timer.start(damage_time)

func _ready():
	set_bullet()

func _physics_process(delta):
	if attack_type == 1:
		position += velocity * delta

func _on_Timer_timeout():
	queue_free()

func _on_Hitbox_area_entered(area):
	if attack_type == 1:
		call_deferred("queue_free")
