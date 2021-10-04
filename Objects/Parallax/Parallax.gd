extends ParallaxBackground

export(float) var speed = 50

func _ready():
	$Sky/Particles.emitting = true

func _process(delta):
	scroll_offset.x += speed * delta
 
