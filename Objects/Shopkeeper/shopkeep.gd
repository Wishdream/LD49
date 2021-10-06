extends Node2D

export var WAIT_TIME = 10
var shop_active = false

func _ready():
	reset_pedestals()
	disable_platform()
	$AnimationPlayer.play("exit")
	$AnimationPlayer.advance(1)

func reset_pedestals():
	for i in $Platform/Pedestals.get_children():
		var index:int
		index = randi() % (Global.items.size()-1)
		
		while true:
			if Global.items[index][0] == Global.ITEMTYPE.AURA:
				var itemind = Global.items[index][1]
				print(Global.aura_id[itemind])
				if Run.items.has(Global.aura_id[itemind]):
					if Run.items[Global.aura_id[itemind]] >= 7:
						index = randi() % (Global.items.size()-1)
						continue
			break
		
		i.index = index
		i.price = randi() % 105 + 45
		
	var i = $Platform/Pedestals.get_child(0)
	i.index = Global.items.size()-1
	i.price = randi() % 25 + 40

func shopkeep_leave():
	$AnimationPlayer.play("exit")

func shopkeep_call():
	$AnimationPlayer.play("entry")

func disable_platform():
	for i in $Platform/Pedestals.get_children():
		i.index = -1
		
	for i in $Platform/Tiles.get_children():
		var body:StaticBody2D = i.get_node("StaticBody2D")
		body.set_collision_layer_bit(1, false)

func enable_platform():
	reset_pedestals()
		
	for i in $Platform/Tiles.get_children():
		var body:StaticBody2D = i.get_node("StaticBody2D")
		body.set_collision_layer_bit(1, true)

func _on_StageTimer_timeout():
	if shop_active:
		shopkeep_leave()
		get_parent().get_node("Stage").modulate = Color.white
		get_parent().get_node("DecayTimer").paused = false
		get_tree().get_current_scene().get_node("StageTimer").start(Global.RUN_TIME * Run.wait_rate)
	else:
		shopkeep_call()
		get_parent().get_node("Stage").modulate = Color.aqua
		get_parent().get_node("DecayTimer").paused = true
		get_tree().get_current_scene().get_node("StageTimer").start(WAIT_TIME)
	shop_active = !shop_active
