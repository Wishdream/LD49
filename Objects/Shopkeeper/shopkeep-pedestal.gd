extends Sprite

export(int) var price:int = 0 setget set_price
export(int) var index:int = 0 setget set_index
var hovered:bool = false setget set_hovered

func _ready():
	set_price(price)
	$Down.visible = false
	$AnimationPlayer.advance(rand_range(0, $AnimationPlayer.current_animation_length))
	
func set_price(value):
	price = value
	
	if price != 0:
		$HBoxContainer/Label.text = str(value)
	else:
		$HBoxContainer/Label.text = "FREE"
		
func set_hovered(value):
	hovered = value
	$Down.visible = hovered
	set_process(hovered)

func set_index(value):
	if value >= 0:
		$Area.monitoring = true
		$Sprite.visible = true
		$HBoxContainer.visible = true
		$AnimationPlayer.stop()
		$AnimationPlayer.play()
		$AnimationPlayer.advance(rand_range(0, $AnimationPlayer.current_animation_length))
		
		var item = Global.items[value]
		
		var frameind = 0
		match item[0]:
			Global.ITEMTYPE.AERIAL:
				frameind = Global.aerial_sprite_index[item[1]]
			Global.ITEMTYPE.AURA:
				frameind = Global.aura_sprite_index[item[1]]
			Global.ITEMTYPE.HAMMER:
				frameind = Global.hammer_sprite_index[item[1]]
			Global.ITEMTYPE.WEAPON:
				frameind = Global.weapon_sprite_index[item[1]]
				
		$Sprite.frame = frameind
		$Down/Name.text = item[2]
		$Down/Description.text = item[3]
	
	else:
		$Area.monitoring = false
		$Sprite.visible = false
		$HBoxContainer.visible = false
		$Down.visible = false
	
func _on_Area_body_entered(body):
	set_hovered(true)
	
func _on_Area_body_exited(body):
	set_hovered(false)
	
func _process(delta):
	if hovered:
		if Input.is_action_just_pressed("move_down"):
			if Run.scrap >= price:
				Run.scrap -= price
				set_index(-1)
				pass
