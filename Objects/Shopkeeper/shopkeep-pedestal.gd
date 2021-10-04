extends Sprite

export(int) var price:int = 0 setget set_price
var active:bool = false

func _ready():
	set_price(price)

func set_price(value):
	price = value
	
	if price != 0:
		$HBoxContainer/Label.text = str(value)
	else:
		$HBoxContainer/Label.text = "FREE"
	
func _on_Area_body_entered(body):
	active = true
	
func _on_Area_body_exited(body):
	active = false
