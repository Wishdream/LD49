extends Control

var huditem = preload("res://Scenes/UI/HUDItem.tscn")

func _ready():
	set_health(10)
	set_scrap(0)
	set_sword(0)
	set_hammer(5)

func set_health(value:int):
	$Health.value = value
	
func set_scrap(value:int):
	$Scrap/Label.text = str(value)

func set_sword(value:int):
	$Sword.index = value

func set_hammer(value:int):
	$Hammer.index = value
	
func add_item(index:int):
	var instance = huditem.instance()
	$ItemContainer.add_child(instance)
	instance.name = str(index)
	instance.index = index

func remove_item(index:int):
	var items = $ItemContainer.get_children()
	var ind = str(index)
	for i in items:
		if (i.name == ind):
			i.queue_free()
			break
