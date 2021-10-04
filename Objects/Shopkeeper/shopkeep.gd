extends Node2D

func _ready():
	reset_pedestals()
	disable_platform()
	$AnimationPlayer.play("exit")
	$AnimationPlayer.advance(1)

func reset_pedestals():
	for i in $Platform/Pedestals.get_children():
		i.index = randi() % Global.items.size()
		i.price = randi() % 200 + 20
		
func shopkeep_leave():
	$AnimationPlayer.play("exit")

func shopkeep_call():
	$AnimationPlayer.play("enter")

func disable_platform():
	for i in $Platform/Pedestals.get_children():
		i.index = -1
		
	for i in $Platform/Tiles.get_children():
		var body:StaticBody2D = i.get_node("StaticBody2D")
		body.set_collision_layer_bit(1, false)

func enable_platform():
	for i in $Platform/Pedestals.get_children():
		i.index = randi() % Global.items.size()
		i.price = randi() % 200 + 20
		
	for i in $Platform/Tiles.get_children():
		var body:StaticBody2D = i.get_node("StaticBody2D")
		body.set_collision_layer_bit(1, true)
