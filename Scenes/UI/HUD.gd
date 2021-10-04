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
	
func update_items():
	for i in $ItemContainer.get_children():
		i.queue_free()
	
	for k in Run.items:
		var instance = huditem.instance()
		$ItemContainer.add_child(instance)
		var sprind = 0
		match k:
			"all_damage":
				sprind = Global.aura_sprite_index[Global.AURA.ALL_DAMAGE]
			"all_hammer":
				sprind = Global.aura_sprite_index[Global.AURA.ALL_HAMMER]
			"more_damage":
				sprind = Global.aura_sprite_index[Global.AURA.MORE_DAMAGE]
			"more_hammer":
				sprind = Global.aura_sprite_index[Global.AURA.MORE_HAMMER]
			"fast_scraphp":
				sprind = Global.aura_sprite_index[Global.AURA.FAST_SCRAPHP]
			"fast_scrapspawn":
				sprind = Global.aura_sprite_index[Global.AURA.FAST_SCRAPSPAWN]
		instance.index = sprind

func remove_item(index:int):
	var items = $ItemContainer.get_children()
	var ind = str(index)
	for i in items:
		if (i.name == ind):
			i.queue_free()
			break

func _on_Player_hp_changed(new_hp):
	set_health(new_hp)

func _on_Player_items_changed():
	set_scrap(Run.scrap)
	set_sword(Run.weapon)
	set_hammer(Run.hammer)
	set_aerial(Run.aerial)
	update_items()


func _on_Player_scrap_changed():
	set_scrap(Run.scrap)


func _on_Player_player_died():
	pass # Replace with function body.
