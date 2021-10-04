extends Node2D
class_name Attack

export(int, 0, 100) var damage_value
export(int, 0, 5) var build_value
export(float) var damage_time = 0.1
export(int, "Attack", "Build", "Damage", "Double") var damage_type = 0
export(int, "Melee", "Projectile") var attack_type = 0
export(Vector2) var velocity = Vector2.ZERO

#export(bool) var fade
var source = null

func set_bullet():
	if damage_type == 0: # Attack from player
		$Hitbox.set_collision_layer_bit(3,true)
		$Hitbox.set_collision_mask_bit(1, true)
		$Hitbox.set_collision_mask_bit(2, true)
		if !$Hitbox.is_connected("body_entered", self, "_on_Hitbox_body_entered"):
			var _signal = $Hitbox.connect("body_entered", self, "_on_Hitbox_body_entered")
	if damage_type == 1: # Build
		$Hitbox.set_collision_layer_bit(4, true)
		$Hitbox.set_collision_mask_bit(1, true)
		if !$Hitbox.is_connected("area_entered", self, "_on_Hitbox_area_entered"):
			var _signal = $Hitbox.connect("area_entered", self, "_on_Hitbox_area_entered")
	if damage_type == 2: # Damage to player
		$Hitbox.set_collision_layer_bit(5, true)
		if !$Hitbox.is_connected("area_entered", self, "_on_Hitbox_area_entered"):
			var _signal = $Hitbox.connect("area_entered", self, "_on_Hitbox_area_entered")
		$Hitbox.set_collision_mask_bit(0, true)
		$Hitbox.set_collision_mask_bit(1, true)
	if damage_type == 3: # Double - Build and attack
		$Hitbox.set_collision_layer_bit(3, true)
		$Hitbox.set_collision_layer_bit(4, true)
		$Hitbox.set_collision_mask_bit(1, true)
		$Hitbox.set_collision_mask_bit(2, true)
		if !$Hitbox.is_connected("area_entered", self, "_on_Hitbox_area_entered"):
			var _signal = $Hitbox.connect("area_entered", self, "_on_Hitbox_area_entered")
		if !$Hitbox.is_connected("body_entered", self, "_on_Hitbox_body_entered"):
			var _signal = $Hitbox.connect("body_entered", self, "_on_Hitbox_body_entered")
	if attack_type == 1:
		$Hitbox.monitoring = true
	$Timer.start(damage_time)

func _ready():
	set_bullet()

func _physics_process(delta):
	if attack_type == 1:
		position += velocity * delta
		
	#if fade:
		#$Sprite.modulate.a = lerp(1,0, 1-($Timer.time_left/$Timer.wait_time))

func _on_Timer_timeout():
	call_deferred("free")

func _on_Hitbox_area_entered(_area):
	hit_registered(_area)

func _on_Hitbox_body_entered(_body):
	hit_registered(_body)

func hit_registered(coll):
	if damage_type != 2:
		# Positive it's only the player doing this
		if (coll.get_parent().get("hp") != null):
			if damage_type == 1 or damage_type == 3:
				source.get_node("Sounds/Repair").pitch_scale = 1.0 + randf()
				source.get_node("Sounds/Repair").play()
			if damage_type != 1 and !coll.get_collision_layer_bit(1):
				if coll.get_parent().hp < 1:
					source.get_node("Sounds/AttackDead").play()
				else:
					source.get_node("Sounds/AttackHit").play()
	call_deferred("free")
