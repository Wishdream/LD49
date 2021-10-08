extends Node

var wait_rate = 1
var scrap_rate = 1
var decay_rate = 1
var attack_rate = 1
var build_rate = 1
var spawn_rate = 1
var hp_rate = 1

var disaster = 0
var wind_dir = Vector2.ZERO

var weapon = Global.WEAPON.DAGGER
var hammer = Global.HAMMER.NORMAL
var aerial = Global.AERIAL.NONE

var scrap = 0
var items = {}

func reset_run():
	wait_rate = 1
	scrap_rate = 1
	decay_rate = 1
	attack_rate = 1
	build_rate = 1
	spawn_rate = 1
	hp_rate = 1
	disaster = 0
	wind_dir = Vector2.ZERO
	weapon = Global.WEAPON.DAGGER
	hammer = Global.HAMMER.NORMAL
	aerial = Global.AERIAL.NONE
	scrap = 0
	items = {}
	
	if OS.is_debug_build():
		weapon = Global.WEAPON.DAGGER
		hammer = Global.HAMMER.NORMAL
		aerial = Global.AERIAL.NONE
		scrap = 0
		items = {"fast_move":7, "more_damage":7, "more_hammer":7, "fast_scraphp":7, "fast_scrapspawn":7}
		
		calculate_aura()

func add_aura(_item):
	match _item:
		Global.AURA.ALL_DAMAGE:
			if !items.has("all_damage"):
				items.all_damage = 1
		Global.AURA.ALL_HAMMER:
			if !items.has("all_hammer"):
				items.all_hammer = 1
		Global.AURA.MORE_DAMAGE:
			if items.has("more_damage"):
				items.more_damage += 1
			else:
				items.more_damage = 1
		Global.AURA.MORE_HAMMER:
			if items.has("more_hammer"):
				items.more_hammer += 1
			else:
				items.more_hammer = 1
		Global.AURA.FAST_MOVE:
			if items.has("fast_move"):
				if items.fast_move < 7:
					items.fast_move += 1
			else:
				items.fast_move = 1
		Global.AURA.FAST_SCRAPHP:
			if items.has("fast_scraphp"):
				items.fast_scraphp += 1
			else:
				items.fast_scraphp = 1
		Global.AURA.FAST_SCRAPSPAWN:
			if items.has("fast_scrapspawn"):
				items.fast_scrapspawn += 1
			else:
				items.fast_scrapspawn = 1
	calculate_aura()

func remove_aura(_item):
	match _item:
		Global.AURA.ALL_DAMAGE:
			if !items.has("all_damage"):
				items.erase("all_damage")
		Global.AURA.ALL_HAMMER:
			if !items.has("all_hammer"):
				items.erase("all_hammer")
		Global.AURA.MORE_DAMAGE:
			if items.has("more_damage"):
				items.more_damage -= 1
			else:
				items.erase("more_damage")
		Global.AURA.MORE_HAMMER:
			if items.has("more_hammer"):
				items.more_hammer -= 1
			else:
				items.erase("more_hammer")
		Global.AURA.FAST_MOVE:
			if items.has("fast_move"):
				items.fast_move -= 1
			else:
				items.erase("fast_move")
		Global.AURA.FAST_SCRAPHP:
			if items.has("fast_scraphp"):
				items.fast_scraphp -= 1
			else:
				items.erase("fast_scraphp")
		Global.AURA.FAST_SCRAPSPAWN:
			if items.has("fast_scrapspawn"):
				items.fast_scrapspawn -= 1
			else:
				items.erase("fast_scrapspawn")
	calculate_aura()
	
func calculate_aura():
	wait_rate = 1
	scrap_rate = 1
	decay_rate = 1
	attack_rate = 1
	build_rate = 1
	hp_rate = 1
	spawn_rate = 1
	if items.has("more_damage"):
		attack_rate += .2 * items.more_damage
		if items.has("more_hammer"):
			build_rate -= .2 * items.more_hammer
	if items.has("more_hammer"):
		build_rate += .2 * items.more_hammer
		if items.has("more_damage"):
			attack_rate -= .2 * items.more_damage
	if items.has("all_damage"):
		attack_rate += 1
		build_rate = 0
	if items.has("all_hammer"):
		build_rate += 1
		attack_rate = 0
	if items.has("all_hammer") and items.has("all_damage"):
		attack_rate = 0
		build_rate = 0
	if items.has("fast_move"):
		wait_rate -= .1 * items.fast_move
		spawn_rate -= .1 * items.fast_move
	if items.has("fast_scraphp"):
		hp_rate += .2 * items.fast_scraphp
		scrap_rate += .2 * items.fast_scraphp
	if items.has("fast_scrapspawn"):
		spawn_rate -= .2 * items.fast_scrapspawn
		scrap_rate += .2 * items.fast_scrapspawn
		
func add_scrap(amount):
	scrap += amount
