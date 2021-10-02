extends Node

var gold_rate = 1
var decay_rate = 1
var hp_rate = 1
var spawn_rate = 1

var disaster = 0
var wind_dir = Vector2.ZERO

var weapon = 0
var hammer = 0
var aerial = 0

var weapon_dura = 0
var hammer_dura = 0

func reset_run():
	gold_rate = 1
	decay_rate = 1
	hp_rate = 1
	spawn_rate = 1

	disaster = 0
	wind_dir = Vector2.ZERO

	weapon = 0
	hammer = 0
	aerial = 0
	
	weapon_dura = 0
	hammer_dura = 0

func add_aura(item):
	pass

func remove_aura(item):
	pass
	
func calculate_aura():
	pass
