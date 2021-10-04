extends Node2D
class_name Block

signal start_fall

var sprite_anim
var sprite_max
var timer
var time_signal
var safe_hp = 5

func _ready():
	sprite_anim = get_node("Collider/Sprite")
	sprite_max = sprite_anim.frames.get_frame_count("default")
	timer = get_tree().get_current_scene().get_node("DecayTimer")
	time_signal = timer.connect("timeout", self, "_on_DecayTimer_timeout")

func _on_DecayTimer_timeout():
	if safe_hp > 0:
		safe_hp = safe_hp - 1
		
	elif sprite_anim.frame < sprite_max-2:
		sprite_anim.frame = sprite_anim.frame + 1
		emit_signal("start_fall")
		
	else:
		sprite_anim.frame = sprite_anim.frame + 1
		$Collider/CollisionShape.disabled = true
		$Collider/Hitbox.monitoring = false
		$Collider/Hitbox.monitorable = false
		if time_signal:
			timer.disconnect("timeout", self, "_onDecayTimer_timeout")

func _on_Hitbox_area_entered(area):
	sprite_anim.frame = sprite_anim.frame - area.get_parent().build_value
