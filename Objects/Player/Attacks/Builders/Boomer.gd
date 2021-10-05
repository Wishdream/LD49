extends Attack

func _ready():
	set_bullet()
	$Hitbox.set_collision_mask_bit(1, false)
	$Hitbox.set_collision_layer_bit(4, false)
	
func _physics_process(delta):
	position += velocity * delta

func _on_Scanbox_area_entered(_area):
	$Hitbox.set_collision_mask_bit(1, true)
	$Hitbox.set_collision_layer_bit(4, true)
