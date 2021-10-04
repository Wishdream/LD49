extends Sprite

export(int) var price:int = 0 setget set_price
export(int) var index:int = 0 setget set_index
var active:bool = false

func _ready():
	set_price(price)
	$Down.visible = false

func set_price(value):
	price = value
	
	if price != 0:
		$HBoxContainer/Label.text = str(value)
	else:
		$HBoxContainer/Label.text = "FREE"

func set_index(value):
	var info = Global.items[value]
	$Sprite.frame = value
	
func _on_Area_body_entered(body):
	active = true
	$Down.visible = true
	
func _on_Area_body_exited(body):
	active = false
	$Down.visible = false
