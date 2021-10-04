extends Area2D

export var SPAWN_TIME = 6
export(int, "Ground", "Air") var SPAWN_TYPE = 0
onready var timer = get_node("Timer")
onready var area_origin = $SpawnArea.global_position
onready var area_extents = $SpawnArea.shape.extents
var spawn_time = SPAWN_TIME

var enemy_walker = load("res://Objects/Enemies/Walker/Walker.tscn")
var enemy_dropper = load("res://Objects/Enemies/Dropper/Dropper.tscn")
var enemy_jumper = load("res://Objects/Enemies/Jumper/Jumper.tscn")
var enemy_flier = load("res://Objects/Enemies/Flier/Flier.tscn")
var enemy_zoomer = load("res://Objects/Enemies/Zoomer/Zoomer.tscn")

func _ready():
	timer.start( (SPAWN_TIME*2) * randf() )

func _on_Timer_timeout():
	var spawn_rate = spawn_time * Run.spawn_rate
	timer.start( 3 + ( (spawn_rate*2) * randf() ) )
	match SPAWN_TYPE:
		0:
			spawn_enemy(randi()%2)
		1:
			spawn_enemy(2 + randi()%3)
	pass

func spawn_enemy(_type):
	var spawn
	match _type:
		0: spawn = enemy_walker.instance()
		1: spawn = enemy_jumper.instance()
		2: spawn = enemy_dropper.instance()
		3: spawn = enemy_flier.instance()
		4: spawn = enemy_zoomer.instance()
	get_tree().get_current_scene().get_node("Enemies").call_deferred("add_child", spawn)
	var pos = area_origin
	pos.x += rand_range(-area_extents.x/2, area_extents.x/2)
	pos.y += rand_range(-area_extents.y/2, area_extents.y/2)
	spawn.position = pos
	$SpawnAudio.play()
	$SpawnAudio.global_position = pos
