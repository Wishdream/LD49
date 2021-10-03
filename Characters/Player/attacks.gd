extends Node

var shot_dir = Vector2.ZERO
var build_normal = load("res://Characters/Player/Attacks/Builders/Normal.tscn")
var build_boomer = load("res://Characters/Player/Attacks/Builders/Boomer.tscn")
var build_better = load("res://Characters/Player/Attacks/Builders/Better.tscn")
var build_area = load("res://Characters/Player/Attacks/Builders/Area.tscn")

func shoot_attack(pos, dir, type):
	var shot
	match type:
		Global.WEAPON.DAGGER:
			pass
		Global.WEAPON.SWORD:
			pass
		Global.WEAPON.SPEAR:
			pass
		Global.WEAPON.HAMMER:
			pass
		Global.WEAPON.PISTOL:
			pass
		Global.WEAPON.SHURIKEN:
			pass
	spawn_bullet(pos, dir, shot)
	pass
	
func shoot_build(pos, dir, type):
	var shot
	match type:
		Global.HAMMER.NORMAL:
			shot = build_normal.instance()
		Global.HAMMER.BOOMER:
			shot = build_boomer.instance()
			shot.source = get_parent()
			shot.get_node("SpritePivot").scale.x = dir
		Global.HAMMER.SPIKE:
			pass
		Global.HAMMER.BETTER:
			shot = build_better.instance()
		Global.HAMMER.AREA:
			shot = build_area.instance()
	
	# Shot movement
	if type != Global.HAMMER.BOOMER:
		shot.velocity *= dir
	
	# Boomer movement
	else: 
		if get_parent().dir != Vector2.ZERO:
			shot.velocity = get_parent().dir * shot.velocity.length()
		else:
			shot.velocity *= dir
			
	spawn_bullet(pos, dir, shot)

func spawn_bullet(pos, dir, shot):
	get_tree().get_current_scene().add_child(shot)
	shot.position = pos
