extends Node2D

func _ready():
	reset_pedestals()

func reset_pedestals():
	for i in $Pedestals.get_children():
		i.index = randi() % Global.items.size()
		i.price = randi() % 200 + 20
