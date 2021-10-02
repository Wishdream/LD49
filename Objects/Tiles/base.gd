extends Node2D

signal update_tick

var sprite_anim
var sprite_max
var timer
var safe_hp = 5

func _ready():
	sprite_anim = get_node("Sprite")
	sprite_max = sprite_anim.frames.get_frame_count("default")
	timer = get_tree().get_current_scene().get_node("DecayTimer")
	timer.connect("timeout", self, "_on_DecayTimer_timeout")
	
func _physics_process(delta):
	

func _on_DecayTimer_timeout():
	emit_signal("update_tick")
	if safe_hp > 0:
		safe_hp = safe_hp - 1
	elif sprite_anim.frame < sprite_max:
		sprite_anim.frame = sprite_anim.frame + 1
	else:
		$Collider.shape_owner_set_disabled(self, true)
		timer.disconnect("timeout", self, "_onDecayTimer_timeout")
