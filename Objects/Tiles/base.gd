extends Node2D
class_name Block

signal start_fall

var sprite_anim
var sprite_max
var timer
var time_signal
var safe_hp = 5
var hpmax = 10.0
var hp = hpmax
var broken

func _ready():
	sprite_anim = get_node("Collider/Sprite")
	sprite_max = sprite_anim.frames.get_frame_count("default")
	timer = get_tree().get_current_scene().get_node("DecayTimer")
	time_signal = timer.connect("timeout", self, "_on_DecayTimer_timeout")

func _on_DecayTimer_timeout():
	if safe_hp > 0:
		safe_hp = safe_hp - 1
	
	if hp > 1:
		sprite_anim.frame = int(sprite_max - hp)
		hp -= 1
		emit_signal("start_fall")
	else:
		sprite_anim.frame = 10
		broken = true
		modulate.a = 0.5
		$Collider.set_collision_layer_bit(1, false)
		if get_node_or_null("Collider/Stuckbox"):
			$Collider/Stuckbox.monitoring = false
		if time_signal:
			timer.disconnect("timeout", self, "_onDecayTimer_timeout")

func _on_Hitbox_area_entered(area):
	if area.get_collision_layer_bit(4):
		$AnimationPlayer.play("flash")
		if hp > hpmax:
			hp = hpmax
			sprite_anim.frame = 0
			if broken:
				broken = false
				modulate.a = 1
				$Collider.set_collision_layer_bit(1, true)
				if get_node_or_null("Collider/Stuckbox"):
					$Collider/Stuckbox.monitoring = true
		else:
			hp += area.get_parent().build_value * Run.build_rate
			sprite_anim.frame = int(sprite_max - hp)

func _on_Stuckbox_body_entered(body:EntityObject):
	if body.get_collision_layer_bit(0) or body.get_collision_layer_bit(2):
		body.position.y -= 32
