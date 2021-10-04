extends Control

var huditem = preload("res://Scenes/UI/HUDItem.tscn")

func _ready():
	set_scrap(Run.scrap)
	set_sword(Run.weapon)
	set_hammer(Run.hammer)
	set_aerial(Run.aerial)

func set_health(value:int):
	$Health.value = value
	
func set_scrap(value:int):
	$Scrap/Label.text = str(value)

func set_sword(value:int):
	$MainItems/Sword.index = Global.weapon_sprite_index[value]

func set_hammer(value:int):
	$MainItems/Hammer.index = Global.hammer_sprite_index[value]

func set_aerial(value:int):
	$MainItems/Aerial.index = Global.aerial_sprite_index[value]
	
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

func _on_Player_hp_changed(new_hp):
	set_health(new_hp)
