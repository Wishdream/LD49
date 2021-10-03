extends Node2D
class_name Attack

export(int, 0, 100) var damage_value
export(int) var damage_time
export(int, "Attack", "Build", "Damage") var damage_type = 0
export(int, "Melee", "Projectile") var attack_type = 0
export(Vector2) var velocity = Vector2.ZERO

func _ready():
	match damage_type:
		0:
			$Hitbox.set_collision_layer_bit(3, true)
		1:
			$Hitbox.set_collision_layer_bit(4, true)
		2:
			$Hitbox.set_collision_layer_bit(2, true)
	$Timer.start(damage_time)


func _physics_process(delta):
	if attack_type == 1:
		position += velocity * delta


func _on_Timer_timeout():
	queue_free()


func _on_Hitbox_body_entered(body):
	queue_free()
