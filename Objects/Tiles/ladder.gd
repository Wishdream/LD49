extends Block

func _on_DecayTimer_timeout():
	._on_DecayTimer_timeout()
	if broken:
		$Collider.set_collision_layer_bit(8, false)

func _on_Hitbox_area_entered(area):
	if area.get_collision_layer_bit(4):
		if hp > hpmax:
			if broken:
				$Collider.set_collision_layer_bit(8, true)
	._on_Hitbox_area_entered(area)
