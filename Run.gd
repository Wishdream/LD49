extends Node

var scrap_rate = 1
var decay_rate = 1
var build_rate = 1
var spawn_rate = 1
var hp_rate = 1

var disaster = 0
var wind_dir = Vector2.ZERO

var weapon = Global.WEAPON.DAGGER
var hammer = Global.HAMMER.BOOMER
var aerial = Global.AERIAL.NONE

var weapon_dura = 0
var hammer_dura = 0

var scrap = 0
var items = {}

func reset_run():
	scrap_rate = 1
	decay_rate = 1
	hp_rate = 1
	spawn_rate = 1
	disaster = 0
	wind_dir = Vector2.ZERO
	weapon = Global.WEAPON.DAGGER
	hammer = Global.HAMMER.NORMAL
	aerial = Global.AERIAL.NONE
	weapon_dura = 0
	hammer_dura = 0
	scrap = 0
	items = {}

func add_aura(_item):
	pass

func remove_aura(_item):
	pass
	
func calculate_aura():
	pass

func add_scrap(amount):
	scrap += amount
