extends StaticBody2D

var sprite_anim
var sprite_max
var safe_hp = 5

func _ready():
	sprite_anim = get_node("Sprite")
	sprite_max = sprite_anim.frames.get_frame_count("default")

func _on_DecayTimer_timeout():
	if safe_hp > 0:
		safe_hp = safe_hp - 1
	elif sprite_anim.frame < sprite_max:
		sprite_anim.frame = sprite_anim.frame + 1
	else:
		$Collider.disabled = true
