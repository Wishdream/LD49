extends Node2D

signal start_fall

var sprite_anim
var sprite_max
var timer
var safe_hp = 5

func _ready():
	sprite_anim = get_node("Collider/Sprite")
	sprite_max = sprite_anim.frames.get_frame_count("default")
	timer = get_tree().get_current_scene().get_node("DecayTimer")
	timer.connect("timeout", self, "_on_DecayTimer_timeout")
	$Collider/Hitbox.connect("area_entered", self, "_on_Hitbox_area_entered")

func _on_DecayTimer_timeout():
	if safe_hp > 0:
		safe_hp = safe_hp - 1
	elif sprite_anim.frame < sprite_max:
		sprite_anim.frame = sprite_anim.frame + 1
		emit_signal("start_fall")
	else:
		$Collider.shape_owner_set_disabled(self, true)
		timer.disconnect("timeout", self, "_onDecayTimer_timeout")

func _on_Hitbox_area_entered(area):
	sprite_anim.frame = sprite_anim.frame - 1
