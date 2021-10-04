extends ParallaxBackground

export(float) var speed = 50
onready var CloudsFront = get_node("CloudsBack")
onready var CloudsBack = get_node("CloudsFront")

func _ready():
	$Sky/Particles.emitting = true

func _process(delta):
	CloudsFront.motion_offset.x += speed * CloudsFront.motion_scale.x * delta
	CloudsBack.motion_offset.x += speed * CloudsBack.motion_scale.x * delta
