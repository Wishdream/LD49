extends Node

export(PackedScene) var scene

func _ready():
	$AnimationPlayer.play("meow")
	print("Hii this is Kaiera!")
	print("I know what you're thinking tho...")
	print("\"Why can I see the debug console?\"")
	print("Godot is like, being weird and we have to export the game in debug mode...")
	print("With that out of the way, have a good day and enjoy the game~!")

func _process(delta):
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select"):
		$AnimationPlayer.stop()
		Transition.scene_change(scene.resource_path)
		#assert(get_tree().change_scene(scene.resource_path) == OK)
	
	var delta_move = 10 * delta
	$"Background/parallax-clouds".position.x -= delta_move
	delta_move = 5 * delta
	$"Background/parallax-clouds2".position.x -= delta_move

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "meow":
		Transition.scene_change(scene.resource_path)
		#assert(get_tree().change_scene(scene.resource_path) == OK)
