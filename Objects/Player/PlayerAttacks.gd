extends Node

var weapon_dagger = load("res://Objects/Player/Attacks/Weapons/Dagger.tscn")
var weapon_sword = load("res://Objects/Player/Attacks/Weapons/Sword.tscn")
var weapon_spear = load("res://Objects/Player/Attacks/Weapons/Spear.tscn")
var weapon_hammer = load("res://Objects/Player/Attacks/Weapons/Hammer.tscn")
var weapon_pistol = load("res://Objects/Player/Attacks/Weapons/Pistol.tscn")
var weapon_shuri = load("res://Objects/Player/Attacks/Weapons/Shuriken.tscn")

var build_normal = load("res://Objects/Player/Attacks/Builders/Normal.tscn")
var build_boomer = load("res://Objects/Player/Attacks/Builders/Boomer.tscn")
var build_spike = load("res://Objects/Player/Attacks/Builders/Spike.tscn")
var build_better = load("res://Objects/Player/Attacks/Builders/Better.tscn")
var build_area = load("res://Objects/Player/Attacks/Builders/Area.tscn")

func shoot_attack(pos, dir, type):
	var shot
	match type:
		Global.WEAPON.DAGGER:
			shot = weapon_dagger.instance()
		Global.WEAPON.SWORD:
			shot = weapon_sword.instance()
		Global.WEAPON.SPEAR:
			shot = weapon_spear.instance()
		Global.WEAPON.HAMMER:
			shot = weapon_hammer.instance()
		Global.WEAPON.PISTOL:
			shot = weapon_pistol.instance()
		Global.WEAPON.SHURIKEN:
			shot = weapon_shuri.instance()
	
	shot.scale.x = dir
	shot.velocity *= dir
	
	spawn_bullet(pos, shot)
	
func shoot_build(pos, dir, type):
	var shot
	match type:
		Global.HAMMER.NORMAL:
			shot = build_normal.instance()
		Global.HAMMER.BOOMER:
			shot = build_boomer.instance()
			shot.source = get_parent()
		Global.HAMMER.SPIKE:
			shot = build_spike.instance()
		Global.HAMMER.BETTER:
			shot = build_better.instance()
		Global.HAMMER.AREA:
			shot = build_area.instance()
	
	# Flip to facing
	shot.scale.x = dir
	
	# Shot movement
	if type != Global.HAMMER.BOOMER:
		shot.velocity *= dir
	
	# Boomer movement
	else: 
		if get_parent().dir != Vector2.ZERO:
			shot.velocity = get_parent().dir * shot.velocity.length()
		else:
			shot.velocity *= dir
			
	spawn_bullet(pos, shot)

func spawn_bullet(pos, shot):
	get_tree().get_current_scene().add_child(shot)
	shot.position = pos
