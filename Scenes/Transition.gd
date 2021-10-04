extends Control

enum {CHANGE_TO, CHANGE, RESTART, QUIT}
var type = 0
var next_scene

func _ready():
	call_deferred("raise")

func scene_to(next):
	type = CHANGE_TO
	process_transition(next)

func scene_change(next):
	type = CHANGE
	process_transition(next)

func restart():
	type = RESTART
	process_transition(null)

func quit():
	type = QUIT
	process_transition(null)


func process_transition(next):
	if !$AnimationPlayer.is_playing():
		next_scene = next
		visible = true
		$AnimationPlayer.queue("enter")

func _on_AnimationPlayer_animation_finished(anim_name):
	$AnimationPlayer.stop()
	if anim_name == "enter":
		$AnimationPlayer.queue("exit")
		match type:
			CHANGE_TO:
				get_tree().change_scene_to(next_scene)
			CHANGE:
				get_tree().change_scene(next_scene)
			RESTART:
				Run.reset_run()
				BGM.stop()
				get_tree().paused = false
				get_tree().reload_current_scene()
				BGM.call_deferred("play","stage")
			QUIT:
				get_tree().quit()
	if anim_name == "exit":
		visible = false
		
